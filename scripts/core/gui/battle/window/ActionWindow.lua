
--[[===============================================================================================

ActionWindow
---------------------------------------------------------------------------------------------------
A window that implements methods in common for battle windows that start an action (TurnWindow, 
Skill Window and Item Window).
Its result is the action time that the character spent.

=================================================================================================]]

-- Imports
local ActionGUI = require('core/gui/battle/ActionGUI')
local ActionInput = require('core/battle/action/ActionInput')
local GridWindow = require('core/gui/GridWindow')
local SkillAction = require('core/battle/action/SkillAction')

-- Alias
local radiusIterator = math.field.radiusIterator

local ActionWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Confirm Action
---------------------------------------------------------------------------------------------------

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
-- Checks if a given skill action is enabled to use.
function ActionWindow:skillActionEnabled(skill)
  if skill.allTiles then
    return true
  else
    local user = TurnManager:currentCharacter()
    local input = ActionInput(skill, user)
    if self:moveEnabled() then
      for tile in FieldManager.currentField:gridIterator() do
        if skill:isSelectable(input, tile) then
          return true
        end
      end
    else
      return #skill:getAllAccessedTiles(input, user:getTile()) > 0
    end
  end
  return false
end
-- Move condition. Enabled if there are any tiles for the character to move to.
function ActionWindow:moveEnabled()
  local user = TurnManager:currentCharacter()
  if user.steps <= 0 then
    return false
  end
  for path in TurnManager:pathMatrix():iterator() do
    if path and path.totalCost <= user.steps then
      return true
    end
  end
  return false
end

---------------------------------------------------------------------------------------------------
-- Cancel Action
---------------------------------------------------------------------------------------------------

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
