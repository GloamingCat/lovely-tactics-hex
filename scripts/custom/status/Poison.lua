
--[[===============================================================================================

Poison
---------------------------------------------------------------------------------------------------
Life-draining status.

=================================================================================================]]

-- Imports
local PopupText = require('core/battle/PopupText')
local Status = require('core/battle/battler/Status')

-- Alias
local floor = math.floor

-- Constants
local attHP = Config.battle.attHP

local Poison = class(Status)

---------------------------------------------------------------------------------------------------
-- Turn callback
---------------------------------------------------------------------------------------------------

function Poison:onTurnStart(char, partyTurn)
  if partyTurn and char.battler.state.hp > 1 then
    self:damage(char, 1)
  end
  Status.onTurnStart(self, char, partyTurn)
end

---------------------------------------------------------------------------------------------------
-- Damage pop-up
---------------------------------------------------------------------------------------------------

function Poison:damage(char, times)
  local pos = char.position
  local popupText = PopupText(pos.x, pos.y - 20, pos.z - 10)
  local value = floor(char.battler.mhp() / 10 * times)
  if value >= char.battler.state.hp then
    value = char.battler.state.hp - 1
  end
  local popupName = 'popup_dmg' .. attHP
  popupText:addLine(value, popupName, popupName)
  char.battler:damage(attHP, value)
  popupText:popup()
end

return Poison
