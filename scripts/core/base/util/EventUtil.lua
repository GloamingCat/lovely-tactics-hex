
--[[===============================================================================================

Event Util
---------------------------------------------------------------------------------------------------
Functions that are loaded from the EventSheet.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local DialogueWindow = require('core/gui/general/window/DialogueWindow')

-- Alias
local deltaTime = love.timer.getDelta

-- Constants
local battleIntroShader = love.graphics.newShader('shaders/BattleIntro.glsl')

local util = {}

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

function util.decodeExpression(sheet, event, expression)
  return loadFormula(expression, 'sheet, event')(sheet, event)
end

---------------------------------------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------------------------------------

function util.luaScript(sheet, event, param)
  loadFunction(param, 'sheet, event')(sheet, event)
end

---------------------------------------------------------------------------------------------------
-- Variables
---------------------------------------------------------------------------------------------------

-- @param(name : string) variable's name
-- @param(expression : string) the expression that returns the new value of the variable
function util.setGlobalVar(sheet, event, param)
  SaveManager.current.vars[param.name] = util.decodeExpression(param.expression)
end
-- @param(name : string) variable's name
-- @param(expression : string) the expression that returns the new value of the variable
function util.setCharacterVar(sheet, event, param)
  event.char.vars[param.name] = util.decodeExpression(param.expression)
end
-- @param(name : string) variable's name
-- @param(expression : string) the expression that returns the new value of the variable
function util.setLocalVar(sheet, event, param)
  sheet.vars[param.name] = util.decodeExpression(param.expression)
end

---------------------------------------------------------------------------------------------------
-- Dialogue
---------------------------------------------------------------------------------------------------

-- @param(id : number) ID of the dialogue window
-- @param(width : number) width of the window (optional)
-- @param(height : number) height of the window (optional)
-- @param(x : number) pixel x of the window (optional)
-- @param(y : number) pixel y of the window (optional)
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
-- @param(id : number) the ID of the window
-- @param(portrait : table) character face
-- @param(message : string) dialogue text
function util.showDialogue(sheet, event, param)
  assert(sheet.gui, 'You must open a GUI first.')
  local window = sheet.gui.dialogues[param.id]
  assert(window, 'You must open window ' .. param.id .. ' first.')
  window:setPortrait(param.portrait)
  window:showDialogue(param.message)
end
-- @param(id : number) ID of the window
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
-- @param(fade : boolean) fade time (optional, no fading by default)
-- @param(fieldID : number) field to loaded's ID
-- @param(intro : boolean) player battle introduction animation
-- @param(gameOverCondition : number) 0 => no gameover, 1 => only when lost, 2 => lost or draw
-- @param(escapeEnabled : boolean) true to enable the whole party to escape
function util.startBattle(sheet, event, param)
  if param.fade then
    local shader = ScreenManager.shader
    ScreenManager.shader = battleIntroShader
    local time = deltaTime()
    while time <= 1 do
      battleIntroShader:send('time', time)
      coroutine.yield()
      time = time + deltaTime()
    end
    ScreenManager.shader = shader
  end
  FieldManager:loadBattle(param.fieldID, param)
end

return util