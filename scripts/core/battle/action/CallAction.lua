
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
  BattleAction.init(self, 0, 1, 'general')
  self.showTargetWindow = false
  self.allTiles = true
end

---------------------------------------------------------------------------------------------------
-- Input callback
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:onConfirm.
function CallAction:onConfirm(input)
  local troop = TroopManager.troops[(input.party or input.user.battler.party)]
  if input.GUI then
    local result = GUIManager:showGUIForResult(CallGUI(troop, input.user == nil))
    if result ~= 0 then
      troop:callMember(result, input.target)
      input.GUI:endGridSelecting()
      return self:execute()
    end
  else
    troop:callMember(input.member, input.target)
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
  return tile.party == (input.party or input.user.battler.party) and not tile:collides(0, 0)
end

return CallAction
