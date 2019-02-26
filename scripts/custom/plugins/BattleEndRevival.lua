
--[[===============================================================================================

Battle End Revival
---------------------------------------------------------------------------------------------------
Revives dead characters at the end of the battle, so they will be alive in the next battle.

=================================================================================================]]

-- Imports
local Battler = require('core/battle/battler/Battler')

---------------------------------------------------------------------------------------------------
-- Battler
---------------------------------------------------------------------------------------------------

-- Called right before the battle field clears up. Revives all characters.
local Battler_onBattleEnd = Battler.onBattleEnd
function Battler:onBattleEnd()
  Battler_onBattleEnd(self)
  if self.state.hp == 0 then
    self.state.hp = 1
  end
end