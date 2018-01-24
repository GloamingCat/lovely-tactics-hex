
--[[===============================================================================================

Battle End Revival
---------------------------------------------------------------------------------------------------
Revives dead characters at the end of the battle, so they will be alive in the next battle.

=================================================================================================]]

local Character = require('core/objects/Character')

local Character_onBattleEnd = Character.onBattleEnd
function Character:onBattleEnd()
  Character_onBattleEnd(self)
  if not self.battler:isAlive() then
    self.battler.state.hp = 1
  end
end