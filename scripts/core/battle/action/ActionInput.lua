
--[[===============================================================================================

ActionInput
---------------------------------------------------------------------------------------------------
An action that represents a full decision for the turn (a movement, a BattleAction and a target).

=================================================================================================]]

-- Imports
local BattleMoveAction = require('core/battle/action/BattleMoveAction')

-- Alias
local expectation = math.randomExpectation

local ActionInput = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(action : BattleAction)
-- @param(user : Character)
-- @param(target : ObjectTile) action target (optional)
-- @param(moveTarget : ObjectTile) BattleMoveAction target (optional)
-- @param(GUI : ActionGUI) current ActionGUI, if any (optional)
function ActionInput:init(action, user, target, moveTarget, GUI)
  self.action = action
  self.user = user
  self.target = target
  self.moveTarget = moveTarget
  self.GUI = GUI
  self.skipAnimations = BattleManager.params.skipAnimations
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

function ActionInput:canExecute()
  if self.action then
    return self.action:canExecute(self)
  end
end
-- Executes the action.
-- @ret(number) the action time cost
function ActionInput:execute()
  self:executeMovement()
  if self.action then
    self.action:onSelect(self)
    return self.action:onConfirm(self)
  end
end
-- Executes the BattleMoveAction to the specified move target.
function ActionInput:executeMovement()
  if self.moveTarget then
    local moveInput = ActionInput(BattleMoveAction(), self.user, self.moveTarget)
    moveInput.skipAnimations = self.skipAnimations
    moveInput:execute()
  end
end
-- String representation.
-- @ret(string) 
function ActionInput:__tostring()
  return 'ActionInput: ' .. tostring(self.action) .. 
    ' | ' .. tostring(self.user) .. 
    ' | ' .. tostring(self.target) .. 
    ' | ' .. tostring(self.moveTarget)
end

return ActionInput
