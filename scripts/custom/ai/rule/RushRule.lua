
--[[===============================================================================================

RushRule
---------------------------------------------------------------------------------------------------
Rule that just ends the turn. May be used when the other rules cannot be used.

=================================================================================================]]

-- Imports
local BattleTactics = require('core/battle/ai/BattleTactics')
local SkillRule = require('core/battle/ai/SkillRule')

local RushRule = class(SkillRule)

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Overrides SkillRule:onSelect.
function RushRule:onSelect(user)
  SkillRule.onSelect(self, user)
  local queue = BattleTactics.closestCharacters(self.input)
  if queue:isEmpty() then
    self.input = nil
    return
  end
  self.input.target = queue:front()
end

return RushRule
