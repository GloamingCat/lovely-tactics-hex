
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
function Status:init(data, state, battler)
  -- General
  self.battler = battler
  self.data = data
  self.state = state or { lifeTime = 0 }
  if self.data.duration >= 0 then
    self.duration = self.data.duration
  else
    self.duration = math.huge
  end
  self.tags = TagMap(self.data.tags)
  print(#self.data.tags)
  -- Attribute bonus
  self.attAdd = {}
  self.attMul = {}
  for i = 1, #self.data.attributes do
    local bonus = self.data.attributes[i]
    local name = Database.attributes[bonus.id].shortName
    self.attAdd[name] = bonus.add / 100
    self.attMul[name] = bonus.mul / 100
  end
  -- Element bonus
  self.elements = {}
  for i = 1, #self.data.elements do
    local bonus = self.data.elements[i]
    self.elements[bonus.id] = bonus.value
  end
end
-- Creates the status from its ID in the database, loading the correct script.
-- @param(data : table) status' data from database file
-- @param(state : table) the persistent state of the status
-- @param(battler : Battler) the battler with the status
function Status.fromData(data, state, battler)
  if data.script.path ~= '' then
    local class = require('custom/' .. data.script.path)
    return class(data, state, battler)
  else
    return Status(data, state, battler)
  end
end
-- String representation.
function Status:__tostring()
  return 'Status: ' .. self.data.id .. ' (' .. self.data.name .. ')'
end

---------------------------------------------------------------------------------------------------
-- Graphics
---------------------------------------------------------------------------------------------------

function Status:addGraphics()
  self.battler.character:setAnimations(self.data.charAnim)
  self.battler.character:replayAnimation()
end

function Status:removeGraphics()
  self.battler.character:setAnimations('default')
  self.battler.character:setAnimations('battle')
  self.battler.character:playAnimation(self.battler.character.animName)
end

---------------------------------------------------------------------------------------------------
-- Turn callbacks
---------------------------------------------------------------------------------------------------

function Status:onTurnStart(partyTurn)
  self.state.lifeTime = self.state.lifeTime + 1
  if self.state.lifeTime > self.duration then
    self.battler.statusList:removeStatus(self)
  end
end

---------------------------------------------------------------------------------------------------
-- Skill callbacks
---------------------------------------------------------------------------------------------------

function Status:onSkillEffect(input, results)
  if self.data.removeOnKO and results.damage and self.battler.state.hp == 0 then
    self.battler.statusList:removeStatus(self)
  end
end

---------------------------------------------------------------------------------------------------
-- Battle callbacks
---------------------------------------------------------------------------------------------------

function Status:onBattleEnd()
  if self.data.removeOnBattleEnd then
    self.battler.statusList:removeStatus(self)
  end
end

return Status
