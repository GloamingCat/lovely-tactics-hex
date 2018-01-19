
--[[===============================================================================================

Battler
---------------------------------------------------------------------------------------------------
A class the holds character's information for battle formula.
Used to represent a battler during battle.roops[self.party]

=================================================================================================]]

-- Imports
local BattlerBase = require('core/battle/BattlerBase')

-- Alias
local max = math.max
local min = math.min

-- Constants
local mhpName = Config.battle.attHP
local mspName = Config.battle.attSP

local Battler = class(BattlerBase)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(data : table) battler's data rom database
-- @param(character : Character)
-- @param(troop : Troop)
function Battler:init(base, character)
  self.key = base.key
  self.party = character.party
  self.character = character
  self.base = base
  -- Base data
  self.data = base.data
  self.att = base.att
  self.attBase = base.attBase
  self.state = base.state
  self.jumpPoints = base.jumpPoints
  self.maxSteps = base.maxSteps
  self.mhp = base.mhp
  self.msp = base.msp
  self.attackSkill = base.attackSkill
  self.skillList = base.skillList
  self.statusList = base.statusList
  self.inventory = base.inventory
  self.equipment = base.equipment
  self.elementFactors = base.elementFactors
  -- Initialize AI
  local ai = base.data.scriptAI
  if ai.path ~= '' then
    self.AI = require('custom/ai/battler/' .. ai.path)(self, ai.param)
  else
    self.AI = nil
  end
end

function Battler:fromData(data, character, save)
  local base = BattlerBase(character.key, data, save)
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Checks if battler is still alive by its HP.
-- @ret(boolean) true if HP greater then zero, false otherwise
function Battler:isAlive()
  return self.state.hp > 0 and not self.statusList:isDead()
end
-- Checks if the character is considered active in the battle.
-- @ret(boolean)
function Battler:isActive()
  return self:isAlive() and not self.statusList:isDeactive()
end
-- Converting to string.
-- @ret(string) a string representation
function Battler:__tostring()
  return 'Battler: ' .. self.name .. ' [Party ' .. self.party .. ']'
end

---------------------------------------------------------------------------------------------------
-- HP and SP damage
---------------------------------------------------------------------------------------------------

-- Damages HP.
-- @param(value : number) the number of the damage
-- @ret(boolean) true if reached 0, otherwise
function Battler:damageHP(value)
  value = self.state.hp - value
  if value <= 0 then
    self.state.hp = 0
    return true
  else
    self.state.hp = min(value, self.mhp())
    return false
  end
end
-- Damages SP.
-- @param(value : number) the number of the damage
-- @ret(boolean) true if reached 0, otherwise
function Battler:damageSP(value)
  value = self.state.sp - value
  if value <= 0 then
    self.state.sp = 0
    return true
  else
    self.state.sp = min(value, self.msp())
    return false
  end
end
-- Decreases the points given by the key.
-- @param(key : string) HP, SP or other designer-defined point type
-- @param(value : number) value to be decreased
function Battler:damage(key, value)
  if key == mhpName then
    self:damageHP(value)
  elseif key == mspName then
    self:damageSP(value)
  else
    return false
  end
  return true
end

---------------------------------------------------------------------------------------------------
-- Turn callbacks
---------------------------------------------------------------------------------------------------

-- Callback for when a new turn begins.
function Battler:onTurnStart(partyTurn)
  if self.AI and self.AI.onTurnStart then
    self.AI:onTurnStart(partyTurn)
  end
  self.statusList:callback('TurnStart', self, partyTurn)
  if partyTurn then
    self.steps = self.maxSteps()
  end
end
-- Callback for when a turn ends.
function Battler:onTurnEnd(partyTurn)
  if self.AI and self.AI.onTurnEnd then
    self.AI:onTurnEnd(partyTurn)
  end
  self.statusList:callback('TurnEnd', self, partyTurn)
end
-- Callback for when this battler's turn starts.
function Battler:onSelfTurnStart(char)
  self.statusList:callback('SelfTurnStart', char)
end
-- Callback for when this battler's turn ends.
function Battler:onSelfTurnEnd(char, result)
  self.statusList:callback('SelfTurnEnd', char, result)
end

---------------------------------------------------------------------------------------------------
-- Skill callbacks
---------------------------------------------------------------------------------------------------

-- Callback for when the character finished using a skill.
function Battler:onSkillUse(input)
  local costs = input.action.costs
  for i = 1, #costs do
    local value = costs[i].cost(self.att)
    self:damage(costs[i].key, value)
  end
  self.statusList:callback('SkillUse', input)
end
-- Callback for when the characters ends receiving a skill's effect.
function Battler:onSkillEffect(input, results)
  self.statusList:callback('SkillEffect', input, results)
end

---------------------------------------------------------------------------------------------------
-- Other callbacks
---------------------------------------------------------------------------------------------------

-- Callback for when the character moves.
-- @param(path : Path) the path that the battler just walked
function Battler:onMove(path)
  self.steps = self.steps - path.totalCost
  self.statusList:callback('Move', self, path)
end
-- Callback for when the battle ends.
function Battler:onBattleStart()
  if self.AI and self.AI.onBattleStart then
    self.AI:onBattleStart(self)
  end
  self.statusList:callback('BattleStart', self)
end
-- Callback for when the battle ends.
function Battler:onBattleEnd()
  if self.AI and self.AI.onBattleEnd then
    self.AI:BattleEnd(self)
  end
  self.statusList:callback('BattleEnd', self)
end

return Battler
