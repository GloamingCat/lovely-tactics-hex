
--[[===============================================================================================

AIRule
---------------------------------------------------------------------------------------------------
A rule that defines a decision in the battle turn, storing only data that are independent from the 
current battle state. Instead of storing state-dependent data, it generates in run time the
ActionInput to be used according to the state.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')

local AIRule = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(action : BattleAction) the BattleAction executed in the rule
function AIRule:init(battler, condition, param)
  self.battler = battler
  self.condition = condition and condition ~= '' and loadformula(condition, 'user')
  self.param = param
end
-- Creates an AIRule from the given rule data.
-- @param(data : table) Rule data with path, param and condition fields.
-- @return(AIRule)
function AIRule:fromData(data, battler)
  local class = self
  if data.path and data.path ~= '' then
    class = require('custom/ai/rule/' .. data.path)
  end
  return class(battler, data.condition, data.param)
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Prepares the rule to be executed (or not, if it's not possible).
-- @param(user : Character)
function AIRule:onSelect(user)
end
-- @ret(string) String identifier.
function AIRule:__tostring()
  return 'AIRule: ' .. self.battler.key
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Checks if a rule can be executed.
-- @ret(boolean)
function AIRule:canExecute()
  if self.condition then
    return self.condition(self.battler)
  else
    return true
  end
end
-- Executes the rule.
-- @ret(number) action time cost
function AIRule:execute()
end

return AIRule
