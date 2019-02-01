
--[[===============================================================================================

AttackRule
---------------------------------------------------------------------------------------------------
The rule for an AI that attacks the character with the highest chance of KO.

=================================================================================================]]

-- Imports
local BattleTactics = require('core/battle/ai/BattleTactics')
local SkillRule = require('core/battle/ai/SkillRule')

-- Alias
local expectation = math.randomExpectation

local AttackRule = class(SkillRule)

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Overrides SkillRule:onSelect.
function AttackRule:onSelect(user)
  SkillRule.onSelect(self, user)
  -- Find target with higher chance of dying
  local oldRand = self.skill.rand
  self.skill.rand = expectation
  local bestTile = nil
  local bestChance = -math.huge
  for char in TroopManager.characterList:iterator() do
    local tile = char:getTile()
    if tile.gui.selectable and tile.gui.reachable then
      local dmg = self.skill:calculateEffectResult(self.skills.effects[1], self.input, char)
      if dmg then
        local chance = (char.battler.state.hp - dmg) / char.battler.mhp()
        if chance > bestChance then
          bestChance = chance
          bestTile = tile
        end
      end
    end
  end
  self.skill.rand = oldRand
  if bestTile then
    self.input.taget = bestTile
  else
    local queue = BattleTactics.closestCharacters(self.input)
    if queue:isEmpty() then
      self.input = nil
    else
      self.input.target = queue:front()
    end
  end
end

return AttackRule
