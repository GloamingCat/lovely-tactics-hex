
--[[===============================================================================================

HideRule
---------------------------------------------------------------------------------------------------
The rule for an AI that moves to the tile with less close enemies.

=================================================================================================]]

-- Imports
local AIRule = require('core/battle/ai/AIRule')
local BattleMoveAction = require('core/battle/action/BattleMoveAction')
local BattleTactics = require('core/battle/ai/BattleTactics')

local HideRule = class(AIRule)

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Overrides AIRule:onSelect.
function HideRule:onSelect(user)
  self.input.action = BattleMoveAction()
  self.input.action:onSelect(self.input)
  -- Find tile to move
  local queue = BattleTactics.runAway(user, self.input)
  if queue:isEmpty() then
    self.input = nil
  else
    self.input.target = queue:front()
  end
end
-- Overrides AIRule:execute.
function HideRule:execute()
  if self.input then
    return self.input:execute()
  end
end

return HideRule
