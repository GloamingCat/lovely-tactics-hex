
--[[===============================================================================================

EscapeRule
---------------------------------------------------------------------------------------------------
The rule for an AI that removes character from battle field.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')
local AIRule = require('core/battle/ai/AIRule')
local EscapeAction = require('core/battle/action/EscapeAction')

local EscapeRule = class(AIRule)

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Overrides AIRule:onSelect.
function EscapeRule:onSelect(user)
  self.input = ActionInput(EscapeAction(), user or TurnManager:currentCharacter())
  self.input.action:onSelect(self.input)
end

return EscapeRule
