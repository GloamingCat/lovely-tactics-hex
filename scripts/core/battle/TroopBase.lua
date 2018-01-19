
--[[===============================================================================================

TroopBase
---------------------------------------------------------------------------------------------------
Stores and manages the troop data and its members.

=================================================================================================]]

-- Imports
local BattlerBase = require('core/battle/BattlerBase')
local List = require('core/datastruct/List')
local TagMap = require('core/datastruct/TagMap')
local Inventory = require('core/battle/Inventory')

local TroopBase = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(data : table) troop's data from database (player's by default)
function TroopBase:init(data)
  data = data or Database.troops[SaveManager.current.playerTroopID]
  self.data = data
  self.tags = TagMap(data.tags)
  local save = SaveManager.current.troops[data.id] or data
  self.save = save
  self.inventory = Inventory(save.items)
  self.gold = save.gold
  self.battlers = {}
  self.current = self:createBattlerList(save.current, true)
  self.backup = self:createBattlerList(save.backup, true)
  self.hidden = self:createBattlerList(save.hidden)
end

function TroopBase:createBattlerList(memberList, init)
  local list = List()
  for i = 1, #memberList do
    local battler = BattlerBase(memberList[i])
    list:add(battler)
    self.battlers[memberList[i].key] = battler
  end
  return list
end

---------------------------------------------------------------------------------------------------
-- Members
---------------------------------------------------------------------------------------------------

-- Searchs for a member with the given key.
-- @param(key : string) member's key
-- @ret(number) the index of the member in the member list (nil if not found)
-- @ret(List) the list the member is in (nil if not found)
function TroopBase:findMember(key, arr)
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
-- Gets the list of all visible members.
-- @ret(List)
function TroopBase:visibleMembers()
  local list = List(self.current)
  list:addAll(self.backup)
  return list
end

---------------------------------------------------------------------------------------------------
-- Persistent Data
---------------------------------------------------------------------------------------------------

function TroopBase:storeSave()
  SaveManager.current.troops[self.data.id] = self:createPersistentData(true)
end
-- Creates the table to represent troop's persistent data.
-- @param(saveFormation : boolean) true to saves modified grid formation (optional)
-- @ret(table)
function TroopBase:createPersistentData(saveFormation)
  if not self.data.persistent then
    return nil
  end
  local data = {}
  data.gold = self.gold
  data.items = self.inventory:getState()
  if saveFormation then
    data.current = self:createDataList(self.current)
    data.backup = self:createDataList(self.backup)
    data.hidden = self:createDataList(self.hidden)
  else
    data.current = self:createDataList(self.save.current)
    data.backup = self:createDataList(self.save.backup)
    data.hidden = self:createDataList(self.save.hidden)
  end
  return data
end
-- @param(arr : table) list of BattlerBase
-- @ret(table) array of save data tables
function TroopBase:createDataList(arr)
  local data = {}
  for i = 1, #arr do
    local battler = arr[i]
    data[i] = self.battlers[battler.key]:createPersistentData()
  end
  return data
end

return TroopBase