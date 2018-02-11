
--[[===============================================================================================

BattlerAI
---------------------------------------------------------------------------------------------------
Implements basic functions to be used in AI classes.

=================================================================================================]]

-- Imports
local AIRule = require('core/battle/ai/AIRule')
local List = require('core/datastruct/List')

local BattlerAI = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(key : string) the AI's identifier (needs to be set by children of this class)
-- @param(battler : Battler)
function BattlerAI:init(rules, battler, param)
  self.battler = battler
  self.rules = List()
  self.param = param
  for i = 1, #rules do
    self.rules:add(AIRule:fromData(rules[i], battler))
  end
end
-- Creates an AI script from the given rule data.
-- @param(data : table) Rule data with path, param and condition fields.
-- @return(BattlerAI)
function BattlerAI:fromData(data, battler)
  local class = self
  if data.path and data.path ~= '' then
    class = require('custom/ai/battler/' .. data.path)
  end
  return class(data.rules, battler, data.param)
end
-- @ret(string) String identifier.
function BattlerAI:__tostring()
  return 'AI: ' .. self.battler.key
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Executes next action of the current character, when it's the character's turn.
-- By default, just skips turn, with no time loss.
-- @param(it : number) the number of iterations since last turn
-- @param(user : Character)
-- @ret(number) action time cost
function BattlerAI:runTurn()
  TurnManager:characterTurnStart()
  local rule = self:nextRule()
  local result = rule:execute()
  TurnManager:characterTurnEnd(result)
  return result
end
-- Selects a rule to be executed.
function BattlerAI:nextRule()
  for i = 1, #self.rules do
    local user = TurnManager:currentCharacter()
    local rule = self.rules[i]
    rule:onSelect(user)
    if self.rules[i]:canExecute() then
      return self.rules[i]
    end
  end
  return AIRule(self.battler)
end

return BattlerAI
