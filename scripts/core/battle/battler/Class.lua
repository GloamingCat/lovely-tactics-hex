
--[[===============================================================================================

Class
---------------------------------------------------------------------------------------------------
Represents a battler's class.

=================================================================================================]]

-- Imports
local List = require('core/datastruct/List')

-- Constants
local attConfig = Config.attributes

local Class = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(battler : Battler) The battler with this class.
-- @param(save : table) Persitent data from save.
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
  for i = 1, #attConfig do
    self.build[attConfig[i].key] = loadformula(classData.build[i], 'lvl')
  end
  self.skills = List(classData.skills)
  self.skills:sort(function(a, b) return a.level < b.level end)
  self.exp = self.exp or self.expCurve(self.level)
end

---------------------------------------------------------------------------------------------------
-- Level-up
---------------------------------------------------------------------------------------------------

-- Increments experience and learns skill if leveled up.
-- @param(exp : number) The quantity of EXP to be added.
function Class:addExperience(exp)
  if self.level == Config.battle.maxLevel then
    return
  end
  self.exp = self.exp + exp
  while self.exp >= self.expCurve(self.level + 1) do
    self.level = self.level + 1
    for i = 1, #self.skills do
      local skill = self.skills[i]
      if self.level >= skill.level then
        self.battler.skillList:learn(skill)
      end
    end
    if self.level == Config.battle.maxLevel then
      self.exp = self.expCurve(self.level)
      return
    end
  end
end
-- Checks if the class levels up with the given EXP.
-- @param(exp : number) The quantity of EXP to be added.
-- @ret(number) The new level, or nil if did not level up.
function Class:levelsup(exp)
  if self.level == Config.battle.maxLevel then
    return nil
  end
  local level = self.level
  exp = exp + self.exp
  while exp >= self.expCurve(level + 1) do
    level = level + 1
  end
  if level > self.level then
    return level
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Converting to string.
-- @ret(string) A string representation.
function Class:__tostring()
  return 'Class: ' .. tostring(self.battler)
end
-- @ret(table) Persistent data table.
function Class:getState()
  local state = {}
  state.id = self.id
  state.exp = self.exp
  state.level = self.level
  return state
end

return Class
