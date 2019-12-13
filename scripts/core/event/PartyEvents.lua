
--[[===============================================================================================

Party Utilities
---------------------------------------------------------------------------------------------------
Functions that are loaded from the EventSheet.

=================================================================================================]]

-- Imports
local Battler = require('core/battle/battler/Battler')
local Troop = require('core/battle/Troop')

local EventSheet = {}

---------------------------------------------------------------------------------------------------
-- Party
---------------------------------------------------------------------------------------------------

-- @param(args.value : number) Value to be added to the party's money.
function EventSheet:increaseMoney(args)
  local save = TroopManager.troopData[TroopManager.playerTroopID .. '']
  save.money = save.money + args.value
end
-- @param(args.key : string) New member's key.
-- @param(args.x : number) Member's grid X (if nil, it's added to backup list).
-- @param(args.y : number) Member's grid Y (if nil, it's added to backup list).
-- @param(args.backup : number) If true, add member to the backup list.
function EventSheet:addMember(args)
  local troop = Troop()
  if args.backup then
    troop:moveMember(args.key, 1)
  else
    troop:moveMember(args.key, 0, args.x, args.y)
  end
  TroopManager:saveTroop(troop, true)
end
-- @param(args.key : string) Member's key.
function EventSheet:hideMember(args)
  local troop = Troop()
  troop:moveMember(args.key, 2)
  TroopManager:saveTroop(troop, true)
end

---------------------------------------------------------------------------------------------------
-- Battler
---------------------------------------------------------------------------------------------------

-- Heal all members' HP and SP.
-- @param(args.onlyCurrent : boolean) True to ignore backup members (false by default).
function EventSheet:healAll(args)
  local troop = Troop()
  for battler in troop:currentBattlers():iterator() do
    battler.state.hp = battler.mhp()
    battler.state.sp = battler.msp()
  end
  if not args.onlyCurrent then
    for battler in troop:backupBattlers():iterator() do
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
function EventSheet:learnSkill(args)
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

return EventSheet
