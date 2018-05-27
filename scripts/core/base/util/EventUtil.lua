
--[[===============================================================================================

Event Utilities
---------------------------------------------------------------------------------------------------
Functions that are loaded from the EventSheet.

=================================================================================================]]

-- Imports
local AIRule = require('core/battle/ai/AIRule')
local TagMap = require('core/base/datastruct/TagMap')

-- Alias
local deltaTime = love.timer.getDelta

local util = {}

---------------------------------------------------------------------------------------------------
-- Other util
---------------------------------------------------------------------------------------------------

do
  local CharacterUtil = require('core/base/util/CharacterUtil')
  local GUIUtil = require('core/base/util/GUIUtil')
  for k, v in pairs(GUIUtil) do
    util[k] = v
  end
  for k, v in pairs(CharacterUtil) do
    util[k] = v
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Calls a Lua script given by a string.
-- @param(args : string) The encoded script.
function util.luaScript(sheet, event, args)
  loadfunction(args, 'sheet, event')(sheet, event)
end
-- Calls a custom event command.
-- @param(args.name : string) The name of the command.
-- @param(args.args : table) Array of custom parameters (key and value).
function util.customCommand(sheet, event, args)
  local commandParam = TagMap(args.args)
  util[args.command](sheet, event, commandParam)
end
-- Interrupts the current executing sheet.
function util.interrupt(sheet, event, args)
  _G.Fiber:interrupt()
end

---------------------------------------------------------------------------------------------------
-- Variables
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(args.name : string) The name of the variable. Two variables of the same type and the 
--  same name will the considered as the same variable.
-- @param(args.expression : string) The expression that returns the new value of the variable.

-- Sets a global variable, accessible from anywhere in the game.
function util.setGlobalVar(sheet, event, args)
  SaveManager.current.vars[args.name] = sheet:decodeExpression(event, args.expression)
end
-- Sets a field variable, accessible from anywhere in the field.
function util.setFieldVar(sheet, event, args)
  FieldManager.currentField.vars[args.name] = sheet:decodeExpression(event, args.expression)
end
-- Sets a character variable, accessible from any sheet of this character.
-- @param(args.key : string) The key of the character.
function util.setCharacterVar(sheet, event, args)
  local char = event[args.key] or FieldManager:search(args.key)
  assert(char, 'Character not found:', args.key or 'nil key')
  char.vars[args.name] = sheet:decodeExpression(event, args.expression)
end
-- Sets a local variable, accessible from this sheet only.
function util.setLocalVar(sheet, event, args)
  sheet.vars[args.name] = sheet:decodeExpression(event, args.expression)
end

---------------------------------------------------------------------------------------------------
-- Screen
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(args.time : number) The duration of the fading in frames.
-- @param(args.wait : boolean) True to wait until the fading finishes.

-- Fades out the screen.
function util.fadeout(sheet, event, args)
  FieldManager.renderer:fadeout(255 / args.time)
  if args.wait then
    _G.Fiber:waitUntil(function()
      return not FieldManager.renderer:colorizing()
    end)
  end
end
-- Fades in the screen.
function util.fadein(sheet, event, args)
  FieldManager.renderer:fadein(255 / args.time)
  if args.wait then
    _G.Fiber:waitUntil(function()
      return not FieldManager.renderer:colorizing()
    end)
  end
end
-- Shows the effect of a shader.
-- @param(args.name : string)
function util.shaderin(sheet, event, args)
  ScreenManager.shader = ResourceManager:loadShader(args.name)
  ScreenManager.shader:send('time', 0)
  local time = deltaTime()
  while time < 1 do
    ScreenManager.shader:send('time', time)
    coroutine.yield()
    time = time + deltaTime() * (args.speed or 1)
  end
  ScreenManager.shader:send('time', 1)
end
-- Hides the effect of a shader.
-- @param(args.name : string)
function util.shaderout(sheet, event, args)
  ScreenManager.shader:send('time', 1)
  local time = deltaTime()
  while time > 0 do
    ScreenManager.shader:send('time', time)
    coroutine.yield()
    time = time - deltaTime() * (args.speed or 1)
  end
  ScreenManager.shader:send('time', 0)
  ScreenManager.shader = nil
end

---------------------------------------------------------------------------------------------------
-- Field
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(args.fade : boolean) Fade time (optional, no fading by default);
-- @param(args.fieldID : number) Field to loaded's ID;

-- Teleports player to other field.
-- @param(args.x : number) Player's destination x.
-- @param(args.y : number) Player's destination y.
-- @param(args.h : number) Player's destination height.
-- @param(args.direction : number) Player's destination direction (in degrees).
function util.moveToField(sheet, event, args)
  local fade = args.fade and {time = args.fade, wait = true}
  if args.fade then
    event.origin.fiberList:fork(function()
      -- Character
      if event.origin.autoTurn then
        event.origin:turnToTile(event.tile.x, event.tile.y)
      end
      event.origin:walkToTile(event.tile:coordinates())
    end)
    util.fadeout(sheet, event, fade)
  end
  FieldManager:loadTransition(args)
  if args.fade then
    FieldManager.renderer:fadeout(0)
    util.fadein(sheet, event, fade)
  end
end
-- Loads battle field.
-- @param(args.intro : boolean) Battle introduction animation.
-- @param(args.gameOverCondition : number) GameOver condition:
--  0 => no gameover, 1 => only when lost, 2 => lost or draw.
-- @param(args.escapeEnabled : boolean) True to enable the whole party to escape.
function util.startBattle(sheet, event, args)
  local fiber = FieldManager.fiberList:fork(function()
    local bgm = AudioManager:pauseBGM()
    ::retry::
    if Config.sounds.battleIntro then
      AudioManager:playSFX(Config.sounds.battleIntro)
    end
    local shaderArgs = {name = 'BattleIntro'}
    if args.fade then
      local shader = ScreenManager.shader
      util.shaderin(sheet, event, shaderArgs)
      if AudioManager.battleTheme then
        AudioManager:playBGM(AudioManager.battleTheme)
      end
      -- TODO: play battle intro SFX
      ScreenManager.shader = shader
    end
    local result = FieldManager:loadBattle(args.fieldID, args)
    if result == 2 then -- Retry
      goto retry
    elseif result == 3 then -- Title Screen
      GameManager:restart()
    elseif bgm then
      AudioManager:playBGM(bgm)
      if args.fade then
        FieldManager.renderer:fadeout(0)
        FieldManager.renderer:fadein(args.fade, true)
      end
    end
  end)
  fiber:waitForEnd()
end

---------------------------------------------------------------------------------------------------
-- Battle
---------------------------------------------------------------------------------------------------

-- Executes a battle rule during AI processing.
-- @param(args.path : string) Path to the rule from "custom/ai/rule/" folder.
-- @param(args.condition : string) Boolean expression that must be true to execute the rule.
-- @param(args.tags : table) Array of tags of the rule.
function util.battleRule(sheet, event, args)
  local rule = AIRule:fromData(args, event.user)
  rule:onSelect(event.origin)
  local condition = args.condition ~= '' and args.condition
  if not condition or sheet:decodeExpression(condition) then
    if rule:canExecute() then
      event.AI.result = rule:execute()
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Sound
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(args.name : string) The path to the sound from audio/bgm (BGMs) or audio/sfx (SFX).
-- @param(args.volume : number) Volume in percentage.
-- @param(args.pitch : number) Pitch in percentage.
-- @param(args.time : number) The duration of the BGM fading transition.
-- @param(args.wait : boolean) Wait for the BGM fading transition or until SFX finishes.

-- Changes the current BGM.
function util.playBGM(sheet, event, args)
  AudioManager:playBGM(args, args.time, args.wait)
end
-- Pauses current BGM.
function util.pauseBGM(sheet, event, args)
  AudioManager:pauseBGM(args, args.time, args.wait)
end
-- Resumes current BGM.
function util.resumeBGM(sheet, event, args)
  AudioManager:resumeBGM(args, args.time, args.wait)
end
-- Play a sound effect.
function util.playSFX(sheet, event, args)
  AudioManager:playSFX(args)
end

return util