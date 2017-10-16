
--[[===============================================================================================

TradeSkill
---------------------------------------------------------------------------------------------------
The SkillAction that is executed when players chooses the Trade action.

=================================================================================================]]

-- Imports
local SkillAction = require('core/battle/action/SkillAction')
local TradeGUI = require('custom/plugins/IndividualItems/TradeGUI')

local TradeSkill = class(SkillAction)

-- Overrides CharacterOnlyAction:isCharacterSelectable.
function TradeSkill:isCharacterSelectable(input, char)
  return (char.battler.party == input.user.battler.party or not char.battler:isAlive()) and 
    (input.user ~= char) and (#input.user.battler.inventory > 0 or #char.battler.inventory > 0)
end
-- Overrides SkillAction:use.
function TradeSkill:use(input)
  input.user:turnToTile(input.target.x, input.target.y)
  local char = input.target.characterList[1]
  GUIManager:showGUIForResult(TradeGUI(input.user, char))
end
-- @ret(string)
function TradeSkill:__tostring()
  return 'TradeSkill (' .. self.data.id .. ')'
end

return TradeSkill
