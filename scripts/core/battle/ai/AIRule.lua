
--[[===============================================================================================

AIRule
---------------------------------------------------------------------------------------------------
A rule that defines a decision in the battle turn, storing only data that are independent from the 
current battle state. Instead of storing state-dependent data, it generates in run time the
ActionInput to be used according to the state.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')
local BattleAction = require('core/battle/action/BattleAction')
local TagMap = require('core/datastruct/TagMap')

local AIRule = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(action : BattleAction) the BattleAction executed in the rule
function AIRule:init(battler, condition, tags)
  self.battler = battler
  self.condition = condition
  self.tags = TagMap(tags)
  self.input = nil
end
-- Creates an AIRule from the given rule data.
-- @param(data : table) Rule data with path, param and condition fields.
-- @ret(AIRule)
function AIRule:fromData(data, battler)
  local class = self
  if data.name and data.name ~= '' then
    class = require('custom/' .. data.name)
  end
  return class(battler, data.condition, data.tags)
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
  if self.input then
    return self.input:canExecute()
  else
    return true
  end
end
-- Executes the rule.
-- @ret(table) The action result table.
function AIRule:execute()
  if self.input then
    return self.input:execute()
  else
    return BattleAction:execute()
  end
end

return AIRule
