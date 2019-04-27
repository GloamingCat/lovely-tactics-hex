
--[[===============================================================================================

DefendRule
---------------------------------------------------------------------------------------------------
The rule for an AI that moves to the safest tile that still has a reachable target.

=================================================================================================]]

-- Imports
local BattleTactics = require('core/battle/ai/BattleTactics')
local SkillRule = require('custom/rule/SkillRule')
local TargetFinder = require('core/battle/ai/TargetFinder')

local DefendRule = class(SkillRule)

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Overrides SkillRule:onSelect.
function DefendRule:onSelect(user)
  SkillRule.onSelect(self, user)
  -- Find tile to attack
  local queue = TargetFinder.closestCharacters(self.input)
  if queue:isEmpty() then
    self.input = nil
    return
  end
  self.input.target = queue:front()
  -- Find tile to move
  queue = BattleTactics.runFromEnemiesToAllies(user, self.input)
  if not queue:isEmpty() then
    self.input.moveTarget = queue:front()
  end
end

return DefendRule
