
--[[===============================================================================================

Troop
---------------------------------------------------------------------------------------------------
Manipulates the matrix of battler IDs to the instatiated in the beginning of the battle.

=================================================================================================]]

-- Imports
local Battler = require('core/battle/battler/Battler')
local Inventory = require('core/battle/Inventory')
local List = require('core/base/datastruct/List')
local Matrix2 = require('core/math/Matrix2')
local TagMap = require('core/base/datastruct/TagMap')
local TroopAI = require('core/battle/ai/TroopAI')

-- Alias
local mod = math.mod

-- Constants
local baseDirection = 315 -- characters' direction at rotation 0
local sizeX = Config.troop.width
local sizeY = Config.troop.height

local Troop = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor. 
-- @param(data : table) troop's data from database
-- @param(party : number) the number of the field party spot this troops was spawned in
function Troop:init(data, party)
  data = data or Database.troops[SaveManager.current.playerTroopID]
  self.data = data
  self.party = party
  self.tags = TagMap(data.tags)
  local save = SaveManager.current.troops[data.id .. ''] or data
  self.save = save
  self.inventory = Inventory(save.items)
  self.gold = save.gold
  self.battlers = {}
  self.current = self:createBattlerList(save.current)
  self.backup = self:createBattlerList(save.backup)
  self.hidden = self:createBattlerList(save.hidden)
  -- Grid
  self.grid = Matrix2(sizeX, sizeY)
  for i = 1, #data.current do
    local member = data.current[i]
    self.grid:set(member, member.x, member.y)
  end
  -- Rotation
  self.rotation = 0
  -- AI
  if data.scriptAI then
    self.AI = TroopAI:fromData(data.scriptAI, self)
  end
end
-- Creates battler for each member data in the given list.
-- @param(memberList : table) an array of member data
function Troop:createBattlerList(memberList)
  local list = List()
  for i = 1, #memberList do
    local battler = Battler(self, memberList[i])
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
-- Gets the list of all visible members.
-- @ret(List)
function Troop:visibleMembers()
  local list = List(self.current)
  list:addAll(self.backup)
  return list
end

---------------------------------------------------------------------------------------------------
-- Rotation
---------------------------------------------------------------------------------------------------

-- Sets the troop rotation (and adapts the ID matrix).
-- @param(r : number) new rotation
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
      local battler = self.grid:get(i, j)
      grid:set(battler, sizeY - j + 1, i)
    end
  end
  self.grid = grid
  self.rotation = mod(self.rotation + 1, 4)
  self.sizeX, self.sizeY = self.sizeY, self.sizeX
end
-- Gets the character direction in degrees.
-- @ret(number)
function Troop:getCharacterDirection()
  return mod(baseDirection + self.rotation * 90, 360)
end

---------------------------------------------------------------------------------------------------
-- Characters
---------------------------------------------------------------------------------------------------

-- Adds a character to the field that represents the member with the given key.
-- @param(key : string) member's key
-- @param(tile : ObjectTile) the tile the character will be put in
-- @ret(Character) the newly created character for the member
function Troop:callMember(key, tile)
  local i = self:findMember(key, self.backup)
  assert(i, 'Could not call member ' .. key .. ': not in backup list.')
  local member = self.backup:remove(i)
  self.current:add(member)
  local dir = self:getCharacterDirection()
  local character = TroopManager:createCharacter(tile, dir, member, self.party)
  TroopManager:createBattler(character)
  return character
end
-- Removes a member character.
-- @param(char : Character)
function Troop:removeMember(char)
  local i = self:findMember(char.key, self.current)
  assert(i, 'Could not remove member ' .. char.key .. ': not in current list.')
  local member = self.current:remove(i)
  self.backup:add(member)
  TroopManager:removeCharacter(char)
end
-- Gets the characters in the field that are in this troop.
-- @param(alive) true to include only alive character, false to only dead, nil to both
-- @ret(List)
function Troop:currentCharacters(alive)
  local characters = List(TroopManager.characterList)
  characters:conditionalRemove(
    function(c)
      return c.party ~= self.party or c.battler:isAlive() == not alive
    end)
  return characters
end

---------------------------------------------------------------------------------------------------
-- Rewards
---------------------------------------------------------------------------------------------------

-- Creates a table of reward from the current state of the battle field.
-- @ret(table) table with exp, items and gold
function Troop:getBattleRewards()
  local r = { exp = {},
    items = Inventory(),
    gold = 0 }
  -- List of living party members
  local characters = self:currentCharacters(true)
  -- Rewards per troop
  for p, troop in pairs(TroopManager.troops) do
    if troop ~= self then
      -- Troop items
      r.items:addAllItems(troop.inventory)
      -- Troop gold
      r.gold = r.gold + troop.gold
      -- Rewards per enemy
      for enemy in troop:currentCharacters():iterator() do
        -- Enemy EXP
        for char in characters:iterator() do
          r.exp[char.key] = (r.exp[char.key] or 0) + enemy.battler.data.exp
        end
        -- Enemy items
        r.items:addAllItems(enemy.battler.inventory)
        -- Enemy gold
        r.gold = r.gold + enemy.battler.data.gold
      end
    end
  end
  return r
end
-- Adds the given rewards to this troop.
-- @param(r : table) the battler results (optional, may be calculated with still in battle)
--  the table must contain <exp>, <items> and <gold> fields
function Troop:addRewards(r)
  r = r or self:getBattleRewards()
  self.gold = self.gold + r.gold
  self.inventory:addAllItems(r.items)
  local characters = self:currentCharacters(true)
  for key, exp in pairs(r.exp) do
    self.battlers[key].class:addExperience(exp)
  end
end

---------------------------------------------------------------------------------------------------
-- Persistent Data
---------------------------------------------------------------------------------------------------

-- Stores this troop in the current save.
-- @param(saveFormation : boolean) true to save modified grid formation (optional)
function Troop:storeSave(saveFormation)
  SaveManager.current.troops[self.data.id .. ''] = self:createPersistentData(saveFormation)
end
-- Creates the table to represent troop's persistent data.
-- @param(saveFormation : boolean) true to save modified grid formation (optional)
-- @ret(table)
function Troop:createPersistentData(saveFormation)
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
-- @param(arr : table) list of Battler
-- @ret(table) array of save data tables
function Troop:createDataList(arr)
  local data = {}
  for i = 1, #arr do
    local battler = arr[i]
    data[i] = self.battlers[battler.key]:createPersistentData()
  end
  return data
end

return Troop