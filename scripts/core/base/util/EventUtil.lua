
--[[===============================================================================================

Event Utilities
---------------------------------------------------------------------------------------------------
Functions that are loaded from the EventSheet.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')
local AIRule = require('core/battle/ai/AIRule')
local ChoiceWindow = require('core/gui/general/window/ChoiceWindow')
local DialogueWindow = require('core/gui/general/window/DialogueWindow')
local GUI = require('core/gui/GUI')
local MoveAction = require('core/battle/action/MoveAction')
local TagMap = require('core/base/datastruct/TagMap')

-- Alias
local deltaTime = love.timer.getDelta

-- Constants
local battleIntroShader = love.graphics.newShader('shaders/BattleIntro.glsl')

local util = {}

---------------------------------------------------------------------------------------------------
-- Auxiliary
---------------------------------------------------------------------------------------------------

local function openGUI(sheet)
  if not sheet.gui then
    sheet.gui = GUI()
    sheet.gui.dialogues = {}
    GUIManager:showGUI(sheet.gui)
  end
end

local function findCharacter(event, key)
  local char = event[key] or FieldManager:search(key)
  assert(char, 'Character not found:', key or 'nil key')
  return char
end

---------------------------------------------------------------------------------------------------
-- Functions
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
-- Dialogue
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(args : table) Argument table.
-- @param(args.id : number) ID of the dialogue window.

-- Opens a new dialogue window and stores in the given ID.
-- @param(args.width : number) Width of the window (optional).
-- @param(args.height : number) Height of the window (optional).
-- @param(args.x : number) Pixel x of the window (optional).
-- @param(args.y : number) Pixel y of the window (optional).
function util.openDialogueWindow(sheet, event, args)
  openGUI(sheet)
  local dialogues = sheet.gui.dialogues
  local window = dialogues[args.id]
  if window then
    window:resize(args.width, args.height)
    window:setXYZ(args.x, args.y)
  else
    window = DialogueWindow(sheet.gui, 
      args.width, args.height, args.x, args.y)
    dialogues[args.id] = window
  end
  window:show()
  sheet.gui:setActiveWindow(window)
end
-- Shows a dialogue in the given window.
-- @param(args.portrait : table) Character face.
-- @param(args.message : string) Dialogue text.
function util.showDialogue(sheet, event, args)
  assert(sheet.gui, 'You must open a GUI first.')
  local window = sheet.gui.dialogues[args.id]
  sheet.gui:setActiveWindow(window)
  assert(window, 'You must open window ' .. args.id .. ' first.')
  -- TODO: dialogue name
  window:showDialogue(args.message, args.portrait, args.name)
end
-- Closes and deletes a dialogue window.
function util.closeDialogueWindow(sheet, event, args)
  if sheet.gui and sheet.gui.dialogues then
    local window = sheet.gui.dialogues[args.id]
    if window then
      window:hide()
      window:removeSelf()
      window:destroy()
      sheet.gui.dialogues[args.id] = nil
    end
  end
end

function util.openChoiceWindow(sheet, event, args)
  openGUI(sheet)
  local window = ChoiceWindow(sheet.gui, args)
  window:show()
  sheet.gui:setActiveWindow(window)
  local result = sheet.gui:waitForResult()
  window:hide()
  window:removeSelf()
  window:destroy()
  sheet.gui.choice = result
end

function util.openPasswordWindow(sheet, event, args)
  -- TODO
end

---------------------------------------------------------------------------------------------------
-- Screen
---------------------------------------------------------------------------------------------------

function util.fadeout(sheet, event, args)
  FieldManager.renderer:fadeout(255 / args.time)
  if args.wait then
    _G.Fiber:waitUntil(function()
      return not FieldManager.renderer:colorizing()
    end)
  end
end

function util.fadein(sheet, event, args)
  FieldManager.renderer:fadein(255 / args.time)
  if args.wait then
    _G.Fiber:waitUntil(function()
      return not FieldManager.renderer:colorizing()
    end)
  end
end

---------------------------------------------------------------------------------------------------
-- Field
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(args : table) Argument table.
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
    if args.fade then
      local previousBGM = AudioManager:pauseBGM()
      -- TODO: play battle intro SFX
      -- TODO: play battle theme
      local shader = ScreenManager.shader
      ScreenManager.shader = battleIntroShader
      local time = deltaTime()
      while time <= 1 do
        battleIntroShader:send('time', time)
        coroutine.yield()
        time = time + deltaTime()
      end
      ScreenManager.shader = nil
    end
    FieldManager:loadBattle(args.fieldID, args)
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
-- @param(args : table) Argument table.
-- @param(args.name : string) The path to the sound from audio/bgm (BGMs) or audio/sfx (SFX).
-- @param(args.volume : number) Volume in percentage.
-- @param(args.pitch : number) Pitch in percentage.
-- @param(args.time : number) The duration of the BGM fading transition.
-- @param(args.wait : boolean) Wait for the BGM fading transition.

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

---------------------------------------------------------------------------------------------------
-- Character
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(args : table) Argument table.
-- @param(args.key : string) The key of the character.
--  "origin" or "dest" to refer to event's characters, or any other key to refer to any other
--  character in the current field.

-- Moves straight to the given tile.
-- @param(args.x : number) Tile x difference.
-- @param(args.y : number) Tile y difference.
-- @param(args.h : number) Tile height difference (0 by default).
function util.moveCharTile(sheet, event, args)
  local char = findCharacter(event, args.key)
  char:walkTiles(args.x, args.y, args.h)
end
-- Moves in the given direction.
-- @param(args.angle : number) The direction in degrees.
-- @param(args.distance : number) The distance to move (in tiles).
function util.moveCharDir(sheet, event, args)
  local char = findCharacter(event, args.key)
  local nextTile = char:frontTile(args.angle)
  if nextTile then
    local ox, oy, oh = char:getTile():coordinates()
    local dx, dy, dh = nextTile:coordinates()
    dx, dy, dh = dx - ox, dy - oy, dh - oh
    dx, dy, dh = dx * args.distance, dy * args.distance, dh * args.distance
    if char.autoTurn then
      char:turnToTile(ox + dx, oy + dy)
    end
    char:walkToTile(ox + dx, oy + dy, oh + dh, false)
  end
end
-- Moves a path to the given tile.
-- @param(args.x : number) Tile destination x.
-- @param(args.y : number) Tile destination y.
-- @param(args.h : number) Tile destination height.
function util.moveCharPath(sheet, event, args)
  local char = findCharacter(event, args.key)
  local tile = FieldManager.currentField:getObjectTile(args.x, args.y, args.h)
  assert(tile, 'Tile not reachable: ', args.x, args.y, args.h)
  local input = ActionInput(MoveAction(), char, tile)
  input.action:execute(input)
end
-- Turns character to the given tile.
-- @param(args.other : string) Key of a character in the destination tile (optional).
-- @param(args.x : number) Tile destination x.
-- @param(args.y : number) Tile destination y.
function util.turnCharTile(sheet, event, args)
  local char = findCharacter(event, args.key)
  if args.other then
    local other = findCharacter(event, args.other)
    local tile = other:getTile()
    char:turnToTile(tile.x, tile.y)
  else
    char:turnToTile(args.x, args.y)
  end
end
-- Turn character to the given direction.
-- @param(args.angle : number) The direction angle in degrees.
function util.turnCharDir(sheet, event, args)
  local char = findCharacter(event, args.key)
  char:setDirection(args.angle)
end
-- Removes a character from the field.
-- @param(args.permanent : boolean) If false, character shows up again when field if reloaded.
function util.deleteChar(sheet, event, args)
  local char = findCharacter(event, args.key)
  if args.permanent then
    char.deleted = true
  end
  char:destroy()
end

return util