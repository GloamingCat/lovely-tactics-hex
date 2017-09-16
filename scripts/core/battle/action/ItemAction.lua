
--[[===============================================================================================

ItemAction
---------------------------------------------------------------------------------------------------

=================================================================================================]]

local SkillAction = require('core/battle/action/CharacterOnlySkill')

local ItemAction = class(SkillAction)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function ItemAction:init(skillID, item)
  SkillAction.init(self, skillID)
  if item.use then
    self:addEffects(item.use.effects)
    self:addStatus(item.use.status)
    if item.use.skillType >= 0 then
      self:setTypeColor(item.use.skillType)
    end
    self.living = item.use.targetType == 0 or item.use.targetType == 2
    self.dead = item.use.targetType == 1 or item.use.targetType == 2
  end
end

function ItemAction:isCharacterSelectable(input, char)
  if char.battler.party ~= input.user.battler.party then
    return false
  end
  if char.battler:isAlive() then
    return self.living
  else
    return self.dead
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Converting to string.
-- @ret(string) a string with skill's ID and name
function ItemAction:__tostring()
  return 'ItemAction (' .. self.skillID .. ': ' .. self.data.name .. ')'
end

return ItemAction
