
--[[===============================================================================================

TroopManager
---------------------------------------------------------------------------------------------------
Creates and manages battle troops.

=================================================================================================]]

-- Imports
local Animation = require('core/graphics/Animation')
local Battler = require('core/battle/battler/Battler')
local Character = require('core/objects/Character')
local List = require('core/datastruct/List')
local Troop = require('core/battle/Troop')

-- Alias
local rand = love.math.random
local mathf = math.field

-- Constants
local charSpeed = (Config.player.dashSpeed + Config.player.walkSpeed) / 2

local TroopManager = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function TroopManager:init()
  self.characterList = List()
  self.troops = {}
  self.troopData = {}
end

---------------------------------------------------------------------------------------------------
-- Troop creation
---------------------------------------------------------------------------------------------------

-- Creates all battle characters based on field's tile data.
function TroopManager:createTroops()
  local parties = FieldManager.currentField.parties
  -- Player's party ID
  local playerID = FieldManager.currentField.playerParty
  if playerID == -1 then
    playerID = rand(#parties)
  else
    playerID = playerID + 1
  end
  self.playerParty = playerID
  self.partyCount = #parties
  -- Create parties
  for i = 1, self.partyCount do
    if i == playerID then
      self:createTroop(TroopManager.playerTroopID, parties[i], i)
    elseif #parties[i].troops > 0 then
      local r = rand(#parties[i].troops)
      self:createTroop(parties[i].troops[r], parties[i], i)
    end
  end
  for char in FieldManager.characterList:iterator() do
    self:createBattler(char)
  end
  self.centers = self:getPartyCenters()
end
-- Creates the troop's characters.
-- @param(troop : TroopManager)
function TroopManager:createTroop(troopID, partyInfo, party)
  local troop = Troop(Database.troops[troopID], party)
  local field = FieldManager.currentField
  troop:setRotation(partyInfo.rotation)
  local dir = troop:getCharacterDirection()
  self.troops[party] = troop
  local sizeX = troop.grid.width
  local sizeY = troop.grid.height
  for i = 1, sizeX do
    for j = 1, sizeY do
      local slot = troop.grid:get(i, j)
      if slot then
        local tile = field:getObjectTile(i - 1 + partyInfo.x, j - 1 + partyInfo.y, partyInfo.h)
        if tile then
          if not tile:collides(0, 0) then
            self:createCharacter(tile, dir, slot, party)
          end
          tile.party = party
        end
      end
    end
  end
  -- Party tiles
  local minx, miny, maxx, maxy
  if partyInfo.rotation == 0 then
    minx, maxx = math.floor(field.sizeX / 3) - 1, math.ceil(field.sizeX * 2 / 3) + 1
    miny, maxy = 0, math.floor(field.sizeY / 3)
  elseif partyInfo.rotation == 1 then
    minx, maxx = 0, math.floor(field.sizeX / 3)
    miny, maxy = math.floor(field.sizeY / 3) - 1, math.ceil(field.sizeY * 2 / 3) + 1
  elseif partyInfo.rotation == 2 then
    minx, maxx = math.floor(field.sizeX / 3) - 1, math.ceil(field.sizeX * 2 / 3) + 1
    miny, maxy = math.floor(field.sizeY * 2 / 3), field.sizeY
  else
    minx, maxx = math.floor(field.sizeX * 2 / 3), field.sizeX
    miny, maxy = math.floor(field.sizeY / 3) - 1, math.ceil(field.sizeY * 2 / 3) + 1
  end
  for x = minx + 1, maxx do
    for y = miny + 1, maxy do
      for h = -1, 1 do
        local tile = field:getObjectTile(x, y, partyInfo.h + h)
        if tile then
          tile.party = party
        end
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Battle characters
---------------------------------------------------------------------------------------------------

-- Creates a new battle character.
-- @param(tile : ObjectTile) the initial tile of the character
-- @param(dir : number) the initial direction of the character
-- @param(member : table) the troop member which this character represents
-- @param(party : number) the number of the field's party spot this character belongs to
-- @ret(BattleCharacter) the newly created character
function TroopManager:createCharacter(tile, dir, member, party)
  local charData = {
    key = member.key,
    charID = member.charID,
    battlerID = member.battlerID,
    party = party,
    animation = 'Idle',
    direction = dir,
    tags = {} }
  charData.x, charData.y, charData.h = tile:coordinates()
  local character = Character(charData)
  character.speed = charSpeed
  return character
end
-- Creates the battler of the character and add the character to the battle character list.
-- @param(character : Character)
-- @param(partyID : number)
function TroopManager:createBattler(character)
  if character.battlerID >= 0 and character.party >= 0 then
    local troop = self.troops[character.party]
    character.battler = troop.battlers[character.key]
    self.characterList:add(character)
    character.battler.statusList:updateGraphics(character)
    if not character.battler:isAlive() then
      character:playAnimation(character.koAnim)
    end
  end
end
-- Removes the given character.
function TroopManager:removeCharacter(char)
  self.characterList:removeElement(char)
  char:destroy()
end

---------------------------------------------------------------------------------------------------
-- Search Functions
---------------------------------------------------------------------------------------------------

-- Searches for the Character with the given Battler.
-- @param(battler : Battler) the battler to search for
-- @ret(Character) the character with the battler (nil of not found)
function TroopManager:getBattlerCharacter(battler)
  for bc in self.characterList:iterator() do 
    if bc.battler == battler then
      return bc
    end
  end
end
-- Searches for the Character with the given battler ID.
-- @param(id : number) the battler ID to search for
-- @ret(Character) the character with the battler ID (nil of not found)
function TroopManager:getBattlerIDCharacter(id)
   for bc in self.characterList:iterator() do 
    if bc.battler.id == id then
      return bc
    end
  end
end
-- Counts the number of characters that have the given battler.
-- @param(battler : table) the data of the battler
-- @ret(number) the number of characters
function TroopManager:getBattlerCount(battler)
  local c = 0
  for char in self.characterList:iterator() do
    if char.battler.data == battler then
      c = c + 1
    end
  end
  return c
end
-- Gets the number of characters in the given party.
-- @param(party : number) party of the character (optional, player's party by default)
-- @ret(number) the number of battler in the party
function TroopManager:getMemberCount(party)
  party = party or self.playerParty
  local count = 0
  for bc in self.characterList:iterator() do
    if bc.party == party then
      count = count + 1
    end
  end
  return count
end

---------------------------------------------------------------------------------------------------
-- Parties
---------------------------------------------------------------------------------------------------

-- Gets the troop controlled by the player.
-- @ret(Troop)
function TroopManager:getPlayerTroop()
  return self.troops[self.playerParty]
end
-- Searchs for a winner party (when all alive characters belong to the same party).
-- @ret(number) the number of the party (returns nil if no one won yet, -1 if there's a draw)
function TroopManager:winnerParty()
  local currentParty = -1
  for bc in self.characterList:iterator() do
    if bc.battler:isAlive() then
      if currentParty == -1 then
        currentParty = bc.party
      else
        if currentParty ~= bc.party then
          return nil
        end
      end
    end
  end
  return currentParty
end
-- Gets the pixel center of each party.
-- @ret(table) array of vectors
function TroopManager:getPartyCenters()
  local centers = {}
  for bc in self.characterList:iterator() do
    local party = bc.party
    local center = centers[party]
    if center then
      center.vector:add(bc.position)
      center.count = centers[party].count + 1
    else
      centers[party] = {
        vector = bc.position:clone(),
        count = 1 }
    end
  end
  for i = 1, #centers do
    local c = centers[i]
    if c then
      c.vector:mul(1 / c.count)
      centers[i] = c.vector
    end
  end
  return centers
end

---------------------------------------------------------------------------------------------------
-- Battle
---------------------------------------------------------------------------------------------------

-- Calls the onBattleStart callback on each troop member.
function TroopManager:onBattleStart()
  for _, troop in pairs(self.troops) do
    local members = troop:visibleMembers()
    for i = 1, #members do
      local char = self:getBattlerCharacter(members[i])
      members[i]:onBattleStart(char)
    end
  end
end
-- Calls the onBattleEnd callback on each troop member.
function TroopManager:onBattleEnd()
  for _, troop in pairs(self.troops) do
    local members = troop:visibleMembers()
    for i = 1, #members do
      local char = self:getBattlerCharacter(members[i])
      members[i]:onBattleEnd(char)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Clear
---------------------------------------------------------------------------------------------------

-- Erases battlers and clears list.
function TroopManager:clear()
  for bc in self.characterList:iterator() do
    bc.battler = nil
    bc.troopSlot = nil
  end
  self.characterList = List()
  self.troopDirections = {}
  self.troops = {}
  self.centers = nil
end
-- Store troop data in save.
-- @param(saveFormation : boolean) True to save modified grid formation (optional).
function TroopManager:saveTroop(troop, saveFormation)
  self.troopData[troop.data.id .. ''] = troop:createPersistentData(saveFormation)
end
-- Store data of all current troops.
function TroopManager:saveTroops()
  for i, troop in pairs(self.troops) do
    if troop.data.persistent then
      self:saveTroop(troop)
    end
  end
end

return TroopManager
