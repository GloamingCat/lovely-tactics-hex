
--[[===============================================================================================

Party Utilities
---------------------------------------------------------------------------------------------------
Functions that are loaded from the EventSheet.

=================================================================================================]]

-- Imports
local Troop = require('core/battle/Troop')

local Event = {}

---------------------------------------------------------------------------------------------------
-- Party
---------------------------------------------------------------------------------------------------

-- @param(args.value : number) Value to be added to the party's money.
function Event:increaseMoney(args)
  local save = TroopManager.troopData[TroopManager.playerTroopID .. '']
  save.money = save.money + args.value
end

---------------------------------------------------------------------------------------------------
-- Battler
---------------------------------------------------------------------------------------------------

-- Heal all members' HP and SP.
-- @param(args.onlyCurrent : boolean) True to ignore backup members (false by default).
function Event:healAll(args)
  local troop = Troop()
  for battler in troop.current:iterator() do
    battler.state.hp = battler.mhp()
    battler.state.sp = battler.msp()
  end
  if not args.onlyCurrent then
    for battler in troop.backup:iterator() do
      battler.state.hp = battler.mhp()
      battler.state.sp = battler.msp()
    end
  end
  TroopManager:saveTroop(troop)
end

return Event
