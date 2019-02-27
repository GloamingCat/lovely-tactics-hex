
--[[===============================================================================================

Status
---------------------------------------------------------------------------------------------------
A generic status effect that a battler may have.
The effects of them on battle and field depend on each individual implementation.

=================================================================================================]]

-- Imports
local BattlerAI = require('core/battle/ai/BattlerAI')
local PopupText = require('core/battle/PopupText')
local TagMap = require('core/datastruct/TagMap')

local Status = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(list : StatusList) the list that included this status
-- @param(data : table) status' data from database file
-- @param(state : table) the persistent state of the status
function Status:init(list, data, state)
  -- General
  self.data = data
  self.statusList = list
  self.lifeTime = state and state.lifeTime or 0
  if self.data.duration >= 0 then
    self.duration = self.data.duration
  else
    self.duration = math.huge
  end
  self.tags = TagMap(self.data.tags)
  -- Attribute bonus
  self.attAdd = {}
  self.attMul = {}
  for i = 1, #data.attributes do
    local bonus = data.attributes[i]
    self.attAdd[bonus.key] = (bonus.add or 0) / 100
    self.attMul[bonus.key] = (bonus.mul or 0) / 100
  end
  -- Element bonus
  self.elementAtk = {}
  self.elementDef = {}
  for i = 1, #data.elementAtk do
    local bonus = data.elementAtk[i]
    self.elementAtk[bonus.id] = (bonus.value or 0) / 100
  end
  for i = 1, #data.elementDef do
    local bonus = data.elementDef[i]
    self.elementDef[bonus.id] = (bonus.value or 0) / 100
  end
  -- AI
  if data.ai and #data.ai > 0 then
    self.AI = BattlerAI(self, data.ai)
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- String representation.
function Status:__tostring()
  return 'Status: ' .. self.data.id .. ' (' .. self.data.name .. ')'
end
-- @ret(table) status' persistent data. Must include its ID.
function Status:getState()
  return { id = self.data.id,
    lifeTime = self.lifeTime }
end

---------------------------------------------------------------------------------------------------
-- Drain / Regen
---------------------------------------------------------------------------------------------------

-- Applies drain effect.
-- @param(char : Character) The battle character with this status.
function Status:drain(char)
  local pos = char.position
  local popupText = PopupText(pos.x, pos.y - 20, pos.z - 60)
  local value = self.data.drainValue
  if self.data.percentage then
    value = math.floor(char.battler['m' .. self.data.drainAtt]() * value / 100)
  end
  if value < 0 then -- Heal
    popupText:addHeal {key = self.data.drainAtt, value = value}
    char.battler:heal(self.data.drainAtt, value)
  else
    popupText:addDamage {key = self.data.drainAtt, value = value}
    char.battler:damage(self.data.drainAtt, value)
  end
  popupText:popup()
  if not char.battler:isAlive() then
    char:playKOAnimation()
  end
end

---------------------------------------------------------------------------------------------------
-- Battle callbacks
---------------------------------------------------------------------------------------------------

-- Removes status in case it's battle-only.
function Status:onBattleEnd()
  if self.data.battleOnly then
    self.statusList:removeStatus(self)
  end
end

---------------------------------------------------------------------------------------------------
-- Turn callbacks
---------------------------------------------------------------------------------------------------

-- Removes status in case its lifetime is over.
-- @param(character : Character)
-- @param(partyTurn : boolean)
function Status:onTurnStart(character, partyTurn)
  if partyTurn and self.data.drainAtt ~= '' then
    self:drain(character)
  end
end

---------------------------------------------------------------------------------------------------
-- Skill callbacks
---------------------------------------------------------------------------------------------------

-- Removes status in case it's removable by damage or KO.
-- @param(input : ActionInput)
-- @param(results : table)
function Status:onSkillEffect(input, results, char)
  local battler = self.statusList.battler
  if results.damage and self.data.removeOnDamage or 
      self.data.removeOnKO and not battler:isAlive() then
    self.statusList:removeStatus(self, char)
  end
end

return Status