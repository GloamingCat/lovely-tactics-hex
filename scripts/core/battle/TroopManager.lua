
--[[===============================================================================================

TroopManager
---------------------------------------------------------------------------------------------------
Creates and manages battle troops.
Parties are troop slots in the field, and they are identified by a number from 0 to the total
number of parties minus 1. A troop contains member information and can be instantied in any party.

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
    playerID = rand(0, #parties - 1)
  else
    playerID = playerID
  end
  self.playerParty = playerID
  -- Create parties
  self.partyCount = #parties
  for i, partyInfo in ipairs(parties) do
    local id = i - 1
    if id == playerID then
      self:createTroop(TroopManager.playerTroopID, partyInfo, id)
    elseif #partyInfo.troops > 0 then
      local r = rand(#partyInfo.troops)
      self:createTroop(partyInfo.troops[r], partyInfo, id)
    end
  end
  for char in FieldManager.characterList:iterator() do
    self:createBattler(char)
  end
  self.centers = self:getPartyCenters()
end
-- Creates the troop's characters.
-- @param(troopID : number) Troop's ID.
-- @param(partyInfo : table) Table with party's members.
-- @param(party : number) Party's ID.
function TroopManager:createTroop(troopID, partyInfo, party)
  local troop = Troop(Database.troops[troopID], party)
  local field = FieldManager.currentField
  troop:setRotation(partyInfo.rotation)
  troop.x = partyInfo.x
  troop.y = partyInfo.y
  self.troops[party] = troop
  if partyInfo.memberGen == 0 then
    return
  end
  local dir = troop:getCharacterDirection()
  for member in troop.members:iterator() do
    if member.list == 0 then
      local i, j = member.x, member.y
      local tile = field:getObjectTile(i - 1 + partyInfo.x, j - 1 + partyInfo.y, partyInfo.h)
      if tile and not tile:collides(0, 0) then
        self:createCharacter(tile, dir, member, party)
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Battle characters
---------------------------------------------------------------------------------------------------

-- Creates the battler of the character and add the character to the battle character list.
-- @param(character : Character) Battler's character.
-- @param(partyID : number) Battler's party.
function TroopManager:createBattler(character)
  if character.party < 0 then
    return
  end
  local troop = self.troops[character.party]
  assert(troop, 'Party not set: ' .. tostring(character.party))
  character.battler = troop.battlers[character.key]
  assert(character.battler, 'Member ' .. tostring(character.key) .. ' not in ' .. tostring(troop))
  self.characterList:add(character)
  character.battler.statusList:updateGraphics(character)
  if not character.battler:isAlive() then
    character:playAnimation(character.koAnim)
  end
end
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
    scripts = {},
    tags = {} }
  charData.x, charData.y, charData.h = tile:coordinates()
  local character = Character(charData)
  character.speed = charSpeed
  return character
end
-- Removes the given character.
function TroopManager:deleteCharacter(char)
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
-- Gets the characters in the field that are in this troop.
-- @param(alive) True to include only alive character, false to only dead, nil to both.
-- @ret(List) List of characters.
function TroopManager:currentCharacters(party, alive)
  local characters = List(self.characterList)
  characters:conditionalRemove(
    function(c)
      return c.party ~= party or c.battler:isAlive() == not alive
    end)
  return characters
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
  for p, c in pairs(centers) do
    c.vector:mul(1 / c.count)
    centers[p] = c.vector
  end
  return centers
end

---------------------------------------------------------------------------------------------------
-- Battle
---------------------------------------------------------------------------------------------------

-- Calls the onBattleStart callback on each troop member.
function TroopManager:onBattleStart()
  for _, troop in pairs(self.troops) do
    for battler in troop:visibleBattlers():iterator() do
      local char = self:getBattlerCharacter(battler)
      battler:onBattleStart(char)
    end
  end
end
-- Calls the onBattleEnd callback on each troop member.
function TroopManager:onBattleEnd()
  for _, troop in pairs(self.troops) do
    for battler in troop:visibleBattlers():iterator() do
      local char = self:getBattlerCharacter(battler)
      battler:onBattleEnd(char)
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
  self.troopData[troop.data.id .. ''] = troop:getState(saveFormation)
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
