
--[[===============================================================================================

Poison
---------------------------------------------------------------------------------------------------
Life-draining status.

=================================================================================================]]

-- Imports
local PopupText = require('core/battle/PopupText')
local Status = require('core/battle/Status')

-- Alias
local floor = math.floor

-- Constants
local attHP = Config.battle.attHP

local Poison = class(Status)

---------------------------------------------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------------------------------------------

function Poison:onTurnStart(partyTurn)
  if partyTurn then
    self:damage(1)
  end
  Status.onTurnStart(self, partyTurn)
end

function Poison:damage(times)
  local pos = self.battler.character.position
  local popupText = PopupText(pos.x, pos.y - 20, pos.z - 10)
  local value = floor(self.battler.mhp() / 10 * times)
  local popupName = 'popup_dmg' .. attHP
  popupText:addLine(value, Color[popupName], Font[popupName])
  self.battler:damage(attHP, value)
  popupText:popup()
end

return Poison
