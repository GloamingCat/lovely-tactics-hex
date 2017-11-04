
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
  local status = self:findStatus(id)
  if status and not data.cumulative then
    status.state.lifeTime = 0
  else
    local top = self:getTopStatus()
    status = Status:fromData(data, state, self.battler)
    self:add(status)
    if status.onAdd then
      status:onAdd()
    end
    if status.data.charAnim ~= '' then
      if not top or status.data.priority >= top.data.priority then
        if top then
          top:removeGraphics()
        end
        print('add graphics')
        status:addGraphics()
      end
    end
  end
  return status
end
-- Removes a status from the list.
-- @param(status : Status or number) the status to be removed or its ID
-- @ret(Status) the removed status
function StatusList:removeStatus(status)
  if type(status) == 'number' then
    status = self:findStatus(status)
  end
  if status then
    local top = self:getTopStatus()
    self:removeElement(status)
    if status.onRemove then
      status:onRemove()
    end
    if top == status then
      status:removeGraphics()
      top = self:getTopStatus()
      if top then
        top:addGraphics()
      end
    end
    return status
  end
end
-- Removes all status instances of the given ID.
-- @param(id : number) status' ID on database
function StatusList:removeAllStatus(id)
  local all = {}
  local status = self:findStatus(id)
  while status do
    self:removeStatus(status)
    all[#all + 1] = status
    status = self:findStatus(id)
  end
  return all
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
    if self[i].data.ko then
      return true
    end
  end
  return false
end

---------------------------------------------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------------------------------------------

function StatusList:callback(name, ...)
  local i = 1
  name = 'on' .. name
  while i <= self.size do
    local s = self[i]
    if s[name] then
      s[name](s, ...)    
      if self[i] == s then
        i = i + 1
      end
    else
      i = i + 1
    end
  end
end

return StatusList
