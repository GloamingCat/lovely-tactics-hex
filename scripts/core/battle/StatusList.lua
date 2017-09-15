
--[[===============================================================================================

StatusList
---------------------------------------------------------------------------------------------------
A special kind of list that provides functions to manage battler's list of status effects.

=================================================================================================]]

-- Imports
local Status = require('core/battle/Status')
local List = require('core/datastruct/List')

-- Alias
local copyTable = util.copyTable
local rand = love.math.random

local StatusList = class(List)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(battler : BattlerBase) the battler whose this list belongs to
-- @param(initialStatus : table) the array with the battler's initiat status (optional)
function StatusList:init(battler, initialStatus)
  List.init(self)
  self.battler = battler
  if initialStatus then
    for i = 1, #initialStatus do
      local s = initialStatus[i]
      local r = rand(100)
      if r <= (s.rate or 100) then
        self:addStatus(s.id, s.state)
      end
    end
  end
end

function StatusList:__tostring()
  return 'Status' .. getmetatable(List).__tostring(self)
end

---------------------------------------------------------------------------------------------------
-- Add / Remove
---------------------------------------------------------------------------------------------------

-- Add a new status.
-- @param(id : number) the status' ID
-- @param(state : table) the status persistent data
-- @ret(Status) newly added status
function StatusList:addStatus(id, state)
  local data = Database.status[id]
  local s = self:findStatus(id)
  if s and not data.cumulative then
    s.state.lifeTime = 0
  else
    s = Status.fromData(data, state, self.battler)
    self:add(s)
    s:onAdd()
    if s.data.charAnim ~= '' then
      local top = self:getTopStatus()
      if s.data.priority >= top.data.priority then
        top:removeGraphics()
        s:setGraphics()
      end
    end
  end
  return s
end
-- Removes a status from the list.
-- @param(status : Status or number) the status to be removed or its ID
-- @ret(Status) the removed status
function StatusList:removeStatus(status)
  if type(status) == 'number' then
    status = self:findStatus(status)
  end
  if status then
    self:removeElement(status)
    status:onRemove()
    return status
  end
end
-- Removes all status instances of the given ID.
-- @param(id : number) status' ID on database
function StatusList:removeAllStatus(id)
  local status = self:findStatus(id)
  while status do
    self:removeStatus(status)
    status = self:findStatus(id)
  end
end

---------------------------------------------------------------------------------------------------
-- Search
---------------------------------------------------------------------------------------------------

-- Gets the status with the higher priority.
-- @ret(Status)
function StatusList:getTopStatus()
  if #self == 0 then
    return nil
  end
  local s = self[1]
  for i = 2, #self do
    if self[i].data.priority > s.data.priority then
      s = self[i]
    end
  end
  return s
end
-- Gets the status with the given ID (the first created).
-- @param(id : number) the status' ID in the database
-- @ret(Status)
function StatusList:findStatus(id)
  for status in self:iterator() do
    if status.id == id then
      return status
    end
  end
  return nil
end
-- Gets all the status states.
-- @ret(table) an array with the state tables
function StatusList:getState()
  local status = {}
  for i = 1, #self do
    local s = self[i]
    status[i] = { 
      id = s.id, 
      state = copyTable(s.state) }
  end
  return status
end

---------------------------------------------------------------------------------------------------
-- Status effects
---------------------------------------------------------------------------------------------------

-- Gets the total attribute bonus given by the current status effects.
-- @param(name : string) the attribute's key
-- @ret(number) the additive bonus
-- @ret(number) multiplicative bonus
function StatusList:attBonus(name)
  local mul = 1
  local add = 0
  for i = 1, #self do
    add = add + (self[i].attAdd[name] or 0)
    mul = mul + (self[i].attMul[name] or 0)
  end
  return add, mul
end
-- Gets the total element factors given by the current status effects.
-- @param(id : number) the element's ID (position in the elements database)
-- @ret(number) the element bonus
function StatusList:elementBonus(id)
  local e = 0
  for i = 1, #self do
    e = e + (self[i].elements[id] or 0)
  end
  return e
end
-- Checks if there's a deactivating status (like sleep or paralizis).
-- @ret(boolean)
function StatusList:isDeactive()
  for i = 1, #self do
    if self[i].data.deactivate then
      return true
    end
  end
  return false
end
-- Checks if there's a status that is equivalent to KO.
function StatusList:isDead()
  for i = 1, #self do
    if self[i].data.deactivate then
      return true
    end
  end
  return false
end

---------------------------------------------------------------------------------------------------
-- Skill Callbacks
---------------------------------------------------------------------------------------------------

-- Callback for when the character finished using a skill.
function StatusList:onSkillUse(input)
  for status in self:iterator() do
    status:onSkillUse(input)
  end
end
-- Callback for when the characters ends receiving a skill's effect.
function StatusList:onSkillEffect(input, results)
  for status in self:iterator() do
    status:onSkillEffect(input, results)
  end
end

---------------------------------------------------------------------------------------------------
-- Turn Callbacks
---------------------------------------------------------------------------------------------------

function StatusList:onTurnStart(partyTurn)
  local i = 1
  while i <= self.size do
    local status = self[i]
    status.state.lifeTime = status.state.lifeTime + 1
    status:onTurnStart(partyTurn)
    if status.state.lifeTime > status.duration then
      self:removeStatus(status)
    else
      i = i + 1
    end
  end
end

function StatusList:onTurnEnd(partyTurn)
  for status in self:iterator() do
    status:onTurnEnd(partyTurn)
  end
end

function StatusList:onSelfTurnStart()
  for status in self:iterator() do
    status:onSelfTurnStart()
  end
end

function StatusList:onSelfTurnEnd(result)
  for status in self:iterator() do
    status:onSelfTurnEnd(result)
  end
end

---------------------------------------------------------------------------------------------------
-- Other Callbacks
---------------------------------------------------------------------------------------------------

function StatusList:onKO()
  for status in self:iterator() do
    status:onKO()
  end
end

function StatusList:onBattleStart()
  for status in self:iterator() do
    status:onBattleStart()
  end
end

function StatusList:onBattleEnd()
  local i = 1
  while i < #self do
    if self[i].data.removeOnBattleEnd then
      self:removeStatus(self[i])
    else
      i = i + 1
    end
  end
end

return StatusList
