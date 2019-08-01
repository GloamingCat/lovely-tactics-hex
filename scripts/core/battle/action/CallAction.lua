
--[[===============================================================================================

CallAction
---------------------------------------------------------------------------------------------------
The BattleAction that is executed when players chooses the "Call Ally" button.

=================================================================================================]]

-- Imports
local BattleAction = require('core/battle/action/BattleAction')
local CallGUI = require('core/gui/battle/CallGUI')

local CallAction = class(BattleAction)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function CallAction:init()
  BattleAction.init(self, 'general')
  self.showTargetWindow = false
  self.allTiles = true
end

---------------------------------------------------------------------------------------------------
-- Input callback
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:onConfirm.
function CallAction:onConfirm(input)
  self.troop = TroopManager.troops[(input.party or input.user.party)]
  if input.GUI then
    local result = GUIManager:showGUIForResult(CallGUI(troop, input.user == nil))
    if result ~= 0 then
      self:callMember(result, input.target)
      input.GUI:endGridSelecting()
      return self:execute()
    end
  else
    self:callMember(input.member, input.target)
  end
end

---------------------------------------------------------------------------------------------------
-- Tile Properties
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:resetTileProperties.
function CallAction:resetTileProperties(input)
  self:resetSelectableTiles(input)
end
-- Overrides BattleAction:resetTileColors.
function CallAction:resetTileColors(input)
  for tile in self.field:gridIterator() do
    if tile.gui.selectable then
      tile.gui:setColor(self.colorName)
    else
      tile.gui:setColor('')
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Selectable Tiles
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:isSelectable.
function CallAction:isSelectable(input, tile)
  return tile.party == (input.party or input.user.party) and not tile:collides(0, 0)
end

---------------------------------------------------------------------------------------------------
-- Troop
---------------------------------------------------------------------------------------------------

-- Adds a character to the field that represents the member with the given key.
-- @param(key : string) Member's key.
-- @param(tile : ObjectTile) The tile the character will be put in.
-- @ret(Character) The newly created character for the member.
function CallAction:callMember(key, tile)
  local member = self.troop:callMember(key, tile)
  local dir = self.troop:getCharacterDirection()
  local character = TroopManager:createCharacter(tile, dir, member, self.troop.party)
  TroopManager:createBattler(character)
  return character
end
-- Removes a member character.
-- @param(char : Character) The characters representing the member to be removed.
-- @ret(table) Removed member's data.
function CallAction:removeMember(character)
  local member = self.troop:removeMember(character.key)
  TroopManager:deleteCharacter(character)
  return member
end

return CallAction
