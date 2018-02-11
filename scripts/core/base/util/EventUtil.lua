
--[[===============================================================================================

Event Utilities
---------------------------------------------------------------------------------------------------
Functions that are loaded from the EventSheet.

=================================================================================================]]

-- Imports
local AIRule = require('core/battle/ai/AIRule')
local DialogueWindow = require('core/gui/general/window/DialogueWindow')
local GUI = require('core/gui/GUI')

-- Alias
local deltaTime = love.timer.getDelta

-- Constants
local battleIntroShader = love.graphics.newShader('shaders/BattleIntro.glsl')

local util = {}

---------------------------------------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------------------------------------

function util.luaScript(sheet, event, param)
  loadfunction(param, 'sheet, event')(sheet, event)
end

---------------------------------------------------------------------------------------------------
-- Variables
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(name : string) The name of the variable. Two variables of the same type and the same name
--  will the considered the same variable.
-- @param(expression : string) The expression that returns the new value of the variable.

-- Sets a global variable, accessible from anywhere in the game.
function util.setGlobalVar(sheet, event, param)
  SaveManager.current.vars[param.name] = sheet:decodeExpression(event, param.expression)
end
-- Sets a character variable, accessible from any sheet of this character.
function util.setCharacterVar(sheet, event, param)
  event.char.vars[param.name] = sheet:decodeExpression(event, param.expression)
end
-- Sets a local variable, accessible from this sheet only.
function util.setLocalVar(sheet, event, param)
  sheet.vars[param.name] = sheet:decodeExpression(event, param.expression)
end

---------------------------------------------------------------------------------------------------
-- Dialogue
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(id : number) ID of the dialogue window.

-- Opens a new dialogue window and stores in the given ID.
-- @param(width : number) Width of the window (optional).
-- @param(height : number) Height of the window (optional).
-- @param(x : number) Pixel x of the window (optional).
-- @param(y : number) Pixel y of the window (optional).
function util.openDialogueWindow(sheet, event, param)
  if not sheet.gui then
    sheet.gui = GUI()
    sheet.gui.dialogues = {}
    GUIManager:showGUI(sheet.gui)
  end
  local dialogues = sheet.gui.dialogues
  local window = dialogues[param.id]
  if window then
    window:resize(param.width, param.height)
    window:setXYZ(param.x, param.y)
  else
    window = DialogueWindow(sheet.gui, 
      param.width, param.height, param.x, param.y)
    dialogues[param.id] = window
  end
  window:show()
  window:activate()
end
-- Shows a dialogue in the given window.
-- @param(portrait : table) Character face.
-- @param(message : string) Dialogue text.
function util.showDialogue(sheet, event, param)
  assert(sheet.gui, 'You must open a GUI first.')
  local window = sheet.gui.dialogues[param.id]
  assert(window, 'You must open window ' .. param.id .. ' first.')
  window:setPortrait(param.portrait)
  -- TODO: dialogue name
  window:showDialogue(param.message)
end
-- Closes and deletes a dialogue window.
function util.closeDialogueWindow(sheet, event, param)
  if sheet.gui and sheet.gui.dialogues then
    local window = sheet.gui.dialogues[param.id]
    if window then
      window:hide()
    end
    window:removeSelf()
    window:destroy()
    sheet.gui.dialogues[param.id] = nil
    if sheet.gui.windowList.size == 0 then
      GUIManager:returnGUI()
      sheet.gui = nil
    end
  end
end

function util.openChoiceWindow(sheet, event, param)
  -- TODO
end

function util.openPasswordWindow(sheet, event, param)
  -- TODO
end

---------------------------------------------------------------------------------------------------
-- Field
---------------------------------------------------------------------------------------------------

-- @param(fade : boolean) fade time (optional, no fading by default)
-- @param(fieldID : number) field to loaded's ID

-- Teleports player to other field.
-- @param(x : number) player's destination x
-- @param(y : number) player's destination y
-- @param(h : number) player's destination height
-- @param(direction : number) player's destination direction (in degrees) 
function util.moveToField(sheet, event, param)
  if param.fade then
    FieldManager.renderer:fadeout(255 / param.fade)
    event.origin:walkToTile(event.tile:coordinates())
  end
  FieldManager:loadTransition(param)
end
-- Loads battle field.
-- @param(intro : boolean) player battle introduction animation
-- @param(gameOverCondition : number) 0 => no gameover, 1 => only when lost, 2 => lost or draw
-- @param(escapeEnabled : boolean) true to enable the whole party to escape
function util.startBattle(sheet, event, param)
  local fiber = FieldManager.fiberList:fork(function()
    if param.fade then
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
    FieldManager:loadBattle(param.fieldID, param)
  end)
  fiber:waitForEnd()
end

---------------------------------------------------------------------------------------------------
-- Battle
---------------------------------------------------------------------------------------------------

-- Executes a battle rule during AI processing.
-- @param(path : string) Path to the rule from "custom/ai/rule/" folder.
-- @param(condition : string) Boolean expression that must be true to execute the rule.
-- @param(tags : table) Array of tags of the rule.
function util.battleRule(sheet, event, param)
  local rule = AIRule:fromData(param, event.user)
  rule:onSelect(event.origin)
  local condition = param.condition ~= '' and param.condition
  if not condition or sheet:decodeExpression(condition) then
    if rule:canExecute() then
      event.AI.result = rule:execute()
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Sound
---------------------------------------------------------------------------------------------------

-- @param(name : string) The path to the sound from audio/bgm (BGMs) or audio/sfx (SFX).
-- @param(volume : number) Volume in percentage.
-- @param(pitch : number) Pitch in percentage.
-- @param(time : number) The duration of the BGM fading transition.
-- @param(wait : boolean) Wait for the BGM fading transition.

-- Changes the current BGM.
function util.playBGM(sheet, event, param)
  AudioManager:playBGM(param, param.time, param.wait)
end
-- Pauses current BGM.
function util.pauseBGM(sheet, event, param)
  AudioManager:pauseBGM(param, param.time, param.wait)
end
-- Resumes current BGM.
function util.resumeBGM(sheet, event, param)
  AudioManager:resumeBGM(param, param.time, param.wait)
end
-- Play a sound effect.
function util.playSFX(sheet, event, param)
  AudioManager:playSFX(param)
end

---------------------------------------------------------------------------------------------------
-- Character
---------------------------------------------------------------------------------------------------

function util.moveCharacter(sheet, event, param)
  -- TODO
end

return util