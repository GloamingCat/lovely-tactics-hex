
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
function Status:init(data, state, equip)
  -- General
  self.data = data
  self.state = state or { lifeTime = 0 }
  if equip then
    self.equip = equip
    self.equipCount = 1
  else
    self.equipCount = 0
  end
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
  self:addBonus(self.data)
end
-- Creates the status from its ID in the database, loading the correct script.
-- @param(data : table) status' data from database file
-- @param(state : table) the persistent state of the status
-- @param(battler : Battler) the battler with the status
function Status:fromData(data, state, battler)
  if data.script.path ~= '' then
    local class = require('custom/' .. data.script.path)
    return class(data, state, battler)
  else
    return self(data, state, battler)
  end
end

function Status:addBonus(data)
  -- Equip attribute bonus
  for i = 1, #data.attributes do
    local bonus = data.attributes[i]
    local name = Database.attributes[bonus.id].shortName
    self.attAdd[name] = bonus.add / 100
    self.attMul[name] = bonus.mul / 100
  end
  -- Equip element bonus
  for i = 1, #data.elements do
    local bonus = data.elements[i]
    self.elements[bonus.id] = bonus.value
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- String representation.
function Status:__tostring()
  return 'Status: ' .. self.data.id .. ' (' .. self.data.name .. ')'
end

---------------------------------------------------------------------------------------------------
-- Graphics
---------------------------------------------------------------------------------------------------

-- Applies graphical effects on the character.
function Status:addGraphics(character)
  character.statusTransform = self.data.transform
  if self.data.charAnim ~= '' then
    character:setAnimations(self.data.charAnim)
    character:replayAnimation()
  elseif self.data.transform then
    character:replayAnimation()
  end
end
-- Clears the applied effects from Status:addGraphics.
function Status:removeGraphics(character)
  if self.data.transform then
    character.statusTransform = nil
  end
  if self.data.charAnim ~= '' then
    character:setAnimations('default')
    character:setAnimations('battle')
    character:playAnimation(self.battler.character.animName)
  end
end

---------------------------------------------------------------------------------------------------
-- Turn callbacks
---------------------------------------------------------------------------------------------------

function Status:onTurnStart(battler, partyTurn)
  self.state.lifeTime = self.state.lifeTime + 1
  if self.state.lifeTime > self.duration then
    battler.statusList:removeStatus(self, battler)
  end
end

---------------------------------------------------------------------------------------------------
-- Skill callbacks
---------------------------------------------------------------------------------------------------

function Status:onSkillEffect(input, results)
  if self.data.removeOnKO and results.damage and input.user.battler.state.hp == 0 then
    input.user.battler.statusList:removeStatus(self, input.user.battler)
  end
end

---------------------------------------------------------------------------------------------------
-- Battle callbacks
---------------------------------------------------------------------------------------------------

function Status:onBattleEnd(battler)
  if self.data.battleOnly then
    battler.statusList:removeStatus(self, battler)
  end
end

return Status
