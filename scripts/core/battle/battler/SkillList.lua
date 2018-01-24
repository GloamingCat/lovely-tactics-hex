
--[[===============================================================================================

SkillList
---------------------------------------------------------------------------------------------------
A special kind of list that provides functions to manage battler's list of skills.

=================================================================================================]]

-- Imports
local SkillAction = require('core/battle/action/SkillAction')
local List = require('core/datastruct/List')

-- Alias
local copyTable = util.copyTable
local rand = love.math.random

local SkillList = class(List)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function SkillList:init(battler, save)
  List.init(self)
  self.battler = battler
  local skills = save and save.skills or battler.data.skills
  for i = 1, #skills do
    local id = skills[i]
    self:add(SkillAction:fromData(id))
  end
end

---------------------------------------------------------------------------------------------------
-- Check / Change
---------------------------------------------------------------------------------------------------

-- @param(id : number) skill's ID
-- @ret(boolean)
function SkillList:containsSkill(id)
  for i = 1, self.size do
    if self[i].data.id == id then
      return true
    end
  end
  return false
end
-- @param(skill : table) entry in the list of skill to learn
function SkillList:learn(skill)
  if self:containsSkill(skill.id) then
    return
  end
  for i = 1, #skill.requirements do
    if not self:containsSkill(skill.requirements[i]) then
      return
    end
  end
  skill = SkillAction:fromData(skill.id)
  self:add(skill)
  return skill
end

---------------------------------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------------------------------

function SkillList:getState()
  local state = {}
  for i = 1, self.size do
    state[#state + 1] = self[i].data.id
  end
  return state
end

return SkillList