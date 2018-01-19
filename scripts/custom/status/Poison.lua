
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

function Poison:onTurnStart(battler, partyTurn)
  if partyTurn and battler.state.hp > 1 then
    self:damage(battler, 1)
  end
  Status.onTurnStart(self, battler, partyTurn)
end

---------------------------------------------------------------------------------------------------
-- Damage pop-up
---------------------------------------------------------------------------------------------------

function Poison:damage(battler, times)
  local pos = battler.character.position
  local popupText = PopupText(pos.x, pos.y - 20, pos.z - 10)
  local value = floor(battler.mhp() / 10 * times)
  if value >= battler.state.hp then
    value = battler.state.hp - 1
  end
  local popupName = 'popup_dmg' .. attHP
  popupText:addLine(value, popupName, popupName)
  battler:damage(attHP, value)
  popupText:popup()
end

return Poison
