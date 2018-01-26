
--[[===============================================================================================

Class
---------------------------------------------------------------------------------------------------
Represents a battler's class.

=================================================================================================]]

-- Imports
local List = require('core/datastruct/List')

local Class = class()

function Class:init(battler, save)
  self.battler = battler
  if save and save.class then
    self.id = save.class.id
    self.level = save.class.level
    self.exp = save.class.exp
  else
    self.id = battler.data.classID
    self.level = battler.data.level
  end
  local classData = Database.classes[self.id]
  self.data = classData
  self.expCurve = loadformula(classData.expCurve, 'lvl')
  self.build = {}
  for key, formula in pairs(classData.build) do
    self.build[key] = loadformula(formula, 'lvl')
  end
  self.skills = List(classData.skills)
  self.skills:sort(function(a, b) return a.level < b.level end)
  self.exp = self.exp or self.expCurve(self.level)
end

---------------------------------------------------------------------------------------------------
-- Level-up
---------------------------------------------------------------------------------------------------

function Class:addExperience(exp)
  self.exp = self.exp + exp
  while self.exp >= self.expCurve(self.level + 1) do
    self.level = self.level + 1
    for i = 1, #self.skills do
      local skill = self.skills[i]
      if self.level >= skill.level then
        self.battler.skillList:learn(skill)
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------------------------------

function Class:getState()
  local state = {}
  state.id = self.id
  state.exp = self.exp
  state.level = self.level
  return state
end

return Class