
local ButtonWindow = require('core/gui/ButtonWindow')
local SkillAction = require('core/battle/action/SkillAction')

--[[===========================================================================

A window that implements methods in common for battle windows that start
an action (TurnWindow, SkillWindow and ItemWindow).

=============================================================================]]

local ActionWindow = ButtonWindow:inherit()

-- Select an action.
-- @param(actionType : class) the class of the action
--  (must inherit from BattleAction) 
function ActionWindow:selectAction(actionType, ...)
  -- Executes action grid selecting.
  BattleManager:selectAction(actionType(...))
  local result = GUIManager:showGUIForResult('battle/ActionGUI')
  if result == 1 then
    -- End of turn.
    self.result = 1
  end
end

-- Select a skill's action.
-- @param(skill : table) the skill data from Database
function ActionWindow:selectSkill(skill)
  local actionType = SkillAction
  if skill.script.path ~= '' then
    actionType = require('custom/' .. skill.script.path)
  end
  self:selectAction(actionType, nil, nil, skill, skill.script.param)
end

-- Closes this window to be replaced by another one.
-- @param(window : ButtonWindow) the new active window
function ActionWindow:changeWindow(window)
  self:hide(true)
  window:show(true)
  window:activate()
end

return ActionWindow
