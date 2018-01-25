
--[[===============================================================================================

ActionWindow
---------------------------------------------------------------------------------------------------
A window that implements methods in common for battle windows that start an action (TurnWindow, 
SkillWindow and ItemWindow).
Its result is the action time that the character spent.

=================================================================================================]]

-- Imports
local ActionGUI = require('core/gui/battle/ActionGUI')
local ActionInput = require('core/battle/action/ActionInput')
local GridWindow = require('core/gui/GridWindow')
local SkillAction = require('core/battle/action/SkillAction')

local ActionWindow = class(GridWindow)

-- Select an action.
-- @param(actionType : class) the class of the action
--  (must inherit from BattleAction) 
function ActionWindow:selectAction(action, input)
  -- Executes action grid selecting.
  input = input or ActionInput(nil, TurnManager:currentCharacter(), nil, nil, self.GUI)
  input.action = action
  action:onSelect(input)
  self.GUI:hide()
  local result = GUIManager:showGUIForResult(ActionGUI(input))
  if result.endCharacterTurn or result.escaped then
    -- End of turn.
    self.result = result
  else
    if input.user then
      FieldManager.renderer:moveToObject(input.user)
    end
    self.GUI:show()
  end
end
-- Closes this window to be replaced by another one.
-- @param(window : GridWindow) the new active window
function ActionWindow:changeWindow(window, showDescription)
  self:hide()
  self:removeSelf()
  if showDescription then
    self.GUI:showDescriptionWindow(window)
  end
  window:insertSelf()
  window:show()
  window:activate()
end

return ActionWindow
