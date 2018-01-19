
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
  self.equip = {}
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

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

function StatusList:__tostring()
  return 'Status' .. getmetatable(List).__tostring(self)
end

---------------------------------------------------------------------------------------------------
-- Add / Remove
---------------------------------------------------------------------------------------------------

-- Add a new status.
-- @param(id : number) the status' ID
-- @param(state : table) the status persistent data
-- @ret(Status) newly added status (or old one, if non-cumulative)
function StatusList:addStatus(id, state, equip, battler)
  local data = Database.status[id]
  local status = self:findStatus(id)
  if status and not data.cumulative then
    status.state.lifeTime = 0
    if equip then
      status.equip = status.equip or equip
      status.equipCount = status.equipCount + 1
    end
  else
    local top = self:getTopStatus()
    status = Status:fromData(data, state)
    self:add(status)
    if status.onAdd then
      status:onAdd(battler)
    end
    if battler and status.data.charAnim ~= '' then
      if not top or status.data.priority >= top.data.priority then
        if top then
          top:removeGraphics(battler.character)
        end
        status:addGraphics(battler.character)
      end
    end
  end
  return status
end
-- Removes a status from the list.
-- @param(status : Status | number) the status to be removed or its ID
-- @ret(Status) the removed status
function StatusList:removeStatus(status, battler)
  if type(status) == 'number' then
    status = self:findStatus(status)
  end
  if status then
    if status.equipCount > 1 and status.data.cumulative then
      status.equipCount = status.equipCount - 1
      return
    end
    local top = self:getTopStatus()
    self:removeElement(status)
    if status.onRemove then
      status:onRemove(battler)
    end
    if battler then
      if top == status then
        status:removeGraphics(battler.character)
        top = self:getTopStatus()
        if top then
          top:addGraphics(battler.character)
        end
      end
    end
    return status
  end
end
-- Removes all status instances of the given ID.
-- @param(id : number) status' ID on database
function StatusList:removeAllStatus(id, battler)
  local all = {}
  local status = self:findStatus(id)
  while status do
    self:removeStatus(status, battler)
    all[#all + 1] = status
    status = self:findStatus(id)
  end
  return all
end

---------------------------------------------------------------------------------------------------
-- Equipment
---------------------------------------------------------------------------------------------------

-- @param(key : string) the key of the equip slot
-- @param(item : table) the equip data from database
function StatusList:setEquip(key, item, battler)
  local slot = self.equip[key]
  if slot then
    for i = 1, #slot do
      self:removeStatus(slot[i], battler)
    end
  end
  slot = {}
  self.equip[key] = slot
  if item then
    for i = 1, #item.equip.status do
      local id = item.equip.status[i]
      self.equip[key] = self:addStatus(id, nil, item, battler)
    end
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
    if status.data.id == id then
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
    if not s.equip then
      status[i] = { 
        id = s.id, 
        state = copyTable(s.state) }
    end
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
    if self[i].data.ko then
      return true
    end
  end
  return false
end

---------------------------------------------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------------------------------------------

-- Calls a certain function in all status in the list.
-- @param(name : string) the name of the event
-- @param(...) other parameters to the callback
function StatusList:callback(name, ...)
  local i = 1
  name = 'on' .. name
  local list = List(self)
  for s in list:iterator() do
    if s[name] then
      s[name](s, ...)  
    end
  end
end

return StatusList
