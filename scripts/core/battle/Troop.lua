
--[[===============================================================================================

Troop
---------------------------------------------------------------------------------------------------
Manipulates the matrix of battler IDs to the instatiated in the beginning of the battle.

=================================================================================================]]

-- Imports
local Battler = require('core/battle/battler/Battler')
local Inventory = require('core/battle/Inventory')
local List = require('core/datastruct/List')
local Matrix2 = require('core/math/Matrix2')

-- Alias
local mod = math.mod
local copyArray = util.array.deepCopy

-- Constants
local baseDirection = math.field.baseDirection() -- characters' direction at rotation 0
local sizeX = Config.troop.width
local sizeY = Config.troop.height

local Troop = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor. 
-- @param(data : table) Troop's data from database.
-- @param(party : number) The number of the field party spot this troops was spawned in.
function Troop:init(data, party)
  data = data or Database.troops[TroopManager.playerTroopID]
  self.data = data
  self.party = party
  self.tags = Database.loadTags(data.tags)
  local save = TroopManager.troopData[data.id .. ''] or data
  self.save = save
  self.inventory = Inventory(save.items)
  self.money = save.money
  -- Members
  self.battlers = {}
  if save.hidden then
    self.hidden = List(save.hidden)
  else
    self.hidden = List()
  end
  self:initBattlerLists(save.members)
  -- Grid
  self.grid = Matrix2(sizeX, sizeY)
  for i = 1, #self.current do
    local member = self.current[i]
    self.grid:set(member, member.x, member.y)
  end
  -- Rotation
  self.rotation = 0
  -- AI
  if data.ai ~= '' then
    self.AI = require('custom/' .. data.ai)
  end
end
-- Creates battler for each member data in the given list.
-- @param(members : table) An array of member data.
function Troop:initBattlerLists(members)
  self.current = List()
  self.backup = List()
  for i = 1, #members do
    local battler = Battler(self, members[i])
    if members[i].list == 0 then
      self.current:add(battler)
    elseif members[i].list == 1 then
      self.backup:add(battler)
    elseif members[i].list == 2 then
      self.hidden:add(battler)
    end
    self.battlers[members[i].key] = battler
  end
end

---------------------------------------------------------------------------------------------------
-- Members
---------------------------------------------------------------------------------------------------

-- Searchs for a member with the given key.
-- @param(key : string) Member's key.
-- @ret(number) The index of the member in the member list (nil if not found).
-- @ret(List) The list containing the member (nil if not found).
function Troop:findMember(key, arr)
  if arr then
    for i = 1, #arr do
      if arr[i].key == key then
        return i, arr
      end
    end
  else
    local i = self:findMember(key, self.current)
    if i then
      return i, self.current
    end
    i = self:findMember(key, self.backup)
    if i then
      return i, self.backup
    end
    i = self:findMember(key, self.hidden)
    if i then
      return i, self.hidden
    end
  end
end
-- @ret(List) List of all visible members.
function Troop:visibleMembers()
  local list = List(self.current)
  list:addAll(self.backup)
  return list
end

---------------------------------------------------------------------------------------------------
-- Rotation
---------------------------------------------------------------------------------------------------

-- Sets the troop rotation (and adapts the ID matrix).
-- @param(r : number) New rotation.
function Troop:setRotation(r)
  for i = mod(r - self.rotation, 4), 1, -1 do
    self:rotate()
  end
end
-- Rotates by 90.
function Troop:rotate()
  local sizeX, sizeY = self.grid.width, self.grid.height
  local grid = Matrix2(sizeY, sizeX)
  for i = 1, sizeX do
    for j = 1, sizeY do
      local member = self.grid:get(i, j)
      grid:set(member, sizeY - j + 1, i)
    end
  end
  self.grid = grid
  self.rotation = mod(self.rotation + 1, 4)
  self.sizeX, self.sizeY = self.sizeY, self.sizeX
end
-- @ret(number) Character direction in degrees.
function Troop:getCharacterDirection()
  return mod(baseDirection + self.rotation * 90, 360)
end

---------------------------------------------------------------------------------------------------
-- Current Members
---------------------------------------------------------------------------------------------------

-- Adds a character to the field that represents the member with the given key.
-- @param(key : string) Member's key.
-- @param(x : number) Grid-x position of the member.
-- @param(y : number) Grid-y position of the member.
-- @ret(Battle) The called member.
function Troop:callMember(key, x, y)
  local i = self:findMember(key, self.backup)
  assert(i, 'Could not call member ' .. key .. ": not in 'backup' list.")
  local battler = self.backup:remove(i)
  self.current:add(battler)
  self.grid:set(battler, x, y)
  return battler
end
-- Removes a member.
-- @param(key : string) Member's key.
-- @ret(Battler) Removed member.
function Troop:removeMember(key)
  local i = self:findMember(key, self.current)
  assert(i, 'Could not remove member ' .. key .. ": not in 'current' list.")
  local battler = self.current:remove(i)
  self.backup:add(battler)
  local x, y = self.grid:positionOf(battler)
  self.grid:set(nil, x, y)
  return battler
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Converting to string.
-- @ret(string) A string representation.
function Troop:__tostring()
  return 'Troop ' .. self.data.id .. ': party ' .. self.party .. ' (' .. self.data.name .. ')'
end
-- Creates the table to represent troop's persistent data.
-- @param(saveFormation : boolean) True to save modified grid formation (optional).
-- @ret(table) Table with persistent data.
function Troop:createPersistentData(saveFormation)
  if not self.data.persistent then
    return nil
  end
  local data = {}
  data.money = self.money
  data.items = self.inventory:getState()
  if saveFormation then
    local members = {}
    for i = 1, #self.current do
      local member = self.current[i]
      members[i] = self.battlers[member.key]:createPersistentData(0, member.x, member.y)
    end
    local n = #members
    for i = 1, #self.backup do
      local member = self.backup[i]
      members[i + n] = self.battlers[member.key]:createPersistentData(1)
    end
    data.members = members
    data.hidden = copyArray(self.hidden)
  else
    local members = {}
    for i = 1, #self.save.members do
      local member = self.save.members[i]
      members[i] = self.battlers[member.key]:createPersistentData(member.list, member.x, member.y)
    end
    data.members = members
    if self.save.hidden then
      data.hidden = copyArray(self.save.hidden)
    end
  end
  return data
end

return Troop
