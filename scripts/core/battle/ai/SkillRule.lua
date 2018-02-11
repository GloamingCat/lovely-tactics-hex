
--[[===============================================================================================

SkillRule
---------------------------------------------------------------------------------------------------
An AIRule that executes a skill defined by the param field "id", which means the id-th skill of the
battler. If there's no such field, it will use battler's attack skill.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')
local AIRule = require('core/battle/ai/AIRule')

local SkillRule = class(AIRule)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(...) AIRule constructor arguments.
function SkillRule:init(...)
  AIRule.init(self, ...)
  local id = self.param and self.param.id
  self.skill = id and self.battler.skillList[id] or self.battler.attackSkill
end
-- Prepares the rule to be executed (or not, if it1s not possible).
-- @param(user : Character)
function SkillRule:onSelect(user)
  self.input = ActionInput(self.skill, user or TurnManager:currentCharacter())
  self.skill:onSelect(self.input)
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Checks if a rule can be executed.
-- @ret(boolean)
function SkillRule:canExecute()
  if not AIRule.canExecute(self) then
    return false
  end
  if self.skill and self.input then
    return self.skill:canExecute(self.input)
  else
    return false
  end
end
-- Executes the rule.
-- @ret(number) action time cost
function SkillRule:execute()
  return self.input:execute()
end

return SkillRule
