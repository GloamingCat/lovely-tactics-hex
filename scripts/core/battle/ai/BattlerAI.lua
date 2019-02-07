
--[[===============================================================================================

BattlerAI
---------------------------------------------------------------------------------------------------
Implements basic functions to be used in AI classes.

=================================================================================================]]

-- Imports
local AIRule = require('core/battle/ai/AIRule')
local BattleCursor = require('core/battle/BattleCursor')

local BattlerAI = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(battler : Battler) The battler with this AI.
-- @param(param : string) Any custom arguments.
function BattlerAI:init(battler, rules)
  self.battler = battler
  self.rules = rules
end
-- @ret(string) String identifier.
function BattlerAI:__tostring()
  return 'AI: ' .. self.battler.key
end
-- Shows the cursor over the current character.
function BattlerAI:showCursor(char)
  FieldManager.renderer:moveToObject(char, nil, true)
  local cursor = BattleCursor()
  cursor:setTile(char:getTile())
  cursor:show()
  local t = 0.5
  while t > 0 do
    t = t - love.timer.getDelta()
    cursor:update()
    coroutine.yield()
  end
  cursor:destroy()
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Executes next action of the current character, when it's the character's turn.
-- By default, just skips turn, with no time loss.
-- @ret(number) The action result table.
function BattlerAI:runTurn()
  local char = TurnManager:currentCharacter()
  self:showCursor(char)
  TurnManager:characterTurnStart()
  local result = self:applyRules(char)
  TurnManager:characterTurnEnd(result)
  return result
end
-- Executes the rules in order until one of them produces a result.
-- @param(char : Character) The battle character executing the rules.
function BattlerAI:applyRules(char)
  for i = 1, #self.rules do
    local rule = AIRule:fromData(self.rules[i], self.battler)
    rule:onSelect(char)
    local condition = rule.condition ~= '' and rule.condition
    if (not condition or self:decodeCondition(condition, char)) and rule:canExecute() then
      return rule:execute()
    end
  end
  return AIRule(self.battler):execute()
end
-- Evaluates a given expression.
-- @param(condition : string) Boolean expression.
-- @param(char : Character) The character executing this script.
-- @ret(boolean) The value of the expression.
function BattlerAI:decodeCondition(condition, char)
  return loadformula(condition, 'AI, user')(self, char)
end

return BattlerAI