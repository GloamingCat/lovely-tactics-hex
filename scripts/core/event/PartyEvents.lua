
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
-- Makes a member learn a new skill.
-- @param(args.member : string) Member's key.
-- @param(args.id : number) Skill's ID.
-- @oaram(args.req : table) Array of requirements (optional).
function Event:learnSkill(args)
  local troop = Troop()
  local battler = troop.battlers[args.key]
  assert(battler, "No battler with key: " .. tostring(args.key))
  if args.req then
    battler.skillList:learn { id = args.id, requirements = args.req }
  else
    battler.skillList:learn(args.id)
  end
  TroopManager:saveTroop(troop)
end

return Event
