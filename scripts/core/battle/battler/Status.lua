
--[[===============================================================================================

Status
---------------------------------------------------------------------------------------------------
A generic status effect that a battler may have.
The effects of them on battle and field depend on each individual implementation.

=================================================================================================]]

-- Imports
local TagMap = require('core/datastruct/TagMap')

local Status = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(data : table) status' data from database file
-- @param(state : table) the persistent state of the status
-- @param(battler : Battler) the battler with the status
function Status:init(data, state)
  -- General
  self.data = data
  self.lifeTime = state and state.lifeTime or 0
  if self.data.duration >= 0 then
    self.duration = self.data.duration
  else
    self.duration = math.huge
  end
  self.tags = TagMap(self.data.tags)
  -- Bonus
  self.attAdd = {}
  self.attMul = {}
  self.elements = {}
  -- Attribute bonus
  for i = 1, #data.attributes do
    local bonus = data.attributes[i]
    local name = Database.attributes[bonus.id].shortName
    self.attAdd[name] = bonus.add / 100
    self.attMul[name] = bonus.mul / 100
  end
  -- Element bonus
  for i = 1, #data.elements do
    local bonus = data.elements[i]
    self.elements[bonus.id] = bonus.value
  end
  -- AI
  local ai = data.scriptAI
  if ai and ai.path ~= '' then
    self.AI = require('custom/ai/battler/' .. ai.path)(self, ai.param)
  end
end
-- Creates the status from its ID in the database, loading the correct script.
-- @param(data : table) status' data from database file
-- @param(...) default contructor parameters
function Status:fromData(data, ...)
  if data.script.path ~= '' then
    local class = require('custom/' .. data.script.path)
    return class(data, ...)
  else
    return self(data, ...)
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- String representation.
function Status:__tostring()
  return 'Status: ' .. self.data.id .. ' (' .. self.data.name .. ')'
end

function Status:getState()
  return { id = self.id,
    lifeTime = self.lifeTime }
end

---------------------------------------------------------------------------------------------------
-- Battle callbacks
---------------------------------------------------------------------------------------------------

-- Removes status in case it's battle-only.
-- @param(character : Character)
function Status:onBattleEnd(character)
  if self.data.battleOnly then
    character.battler.statusList:removeStatus(self, character)
  end
end

---------------------------------------------------------------------------------------------------
-- Turn callbacks
---------------------------------------------------------------------------------------------------

-- Removes status in case its lifetime is over.
-- @param(character : Character)
-- @param(partyTurn : boolean)
function Status:onTurnStart(character, partyTurn)
  self.lifeTime = self.lifeTime + 1
  if self.lifeTime > self.duration then
    character.battler.statusList:removeStatus(self, character)
  end
end

---------------------------------------------------------------------------------------------------
-- Skill callbacks
---------------------------------------------------------------------------------------------------

-- Removes status in case it's removable by damage or KO.
-- @param(input : ActionInput)
-- @param(results : table)
function Status:onSkillEffect(input, results)
  if results.damage then
    if self.data.removeOnDamage or not input.user.battler:isAlive() and self.data.removeOnKO then
      input.user.battler.statusList:removeStatus(self, input.user)
    end
  end
end

return Status