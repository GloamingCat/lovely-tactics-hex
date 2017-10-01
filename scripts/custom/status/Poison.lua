
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
-- Turn callback
---------------------------------------------------------------------------------------------------

function Poison:onTurnStart(partyTurn)
  if partyTurn and self.battler.state.hp > 1 then
    self:damage(1)
  end
  Status.onTurnStart(self, partyTurn)
end

---------------------------------------------------------------------------------------------------
-- Damage pop-up
---------------------------------------------------------------------------------------------------

function Poison:damage(times)
  local pos = self.battler.character.position
  local popupText = PopupText(pos.x, pos.y - 20, pos.z - 10)
  local value = floor(self.battler.mhp() / 10 * times)
  if value >= self.battler.state.hp then
    value = self.battler.state.hp - 1
  end
  local popupName = 'popup_dmg' .. attHP
  popupText:addLine(value, Color[popupName], Fonts[popupName])
  self.battler:damage(attHP, value)
  popupText:popup()
end

return Poison
