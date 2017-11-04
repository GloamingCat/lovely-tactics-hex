
--[[===============================================================================================

ItemAction
---------------------------------------------------------------------------------------------------
A type of SkillAction that gets its effect from item data.

=================================================================================================]]

local SkillAction = require('core/battle/action/SkillAction')

local ItemAction = class(SkillAction)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function ItemAction:init(skillID, item)
  SkillAction.init(self, skillID)
  if item.use then
    if item.use.hpEffect then
      self:addEffect('hp', item.use.hpEffect)
    end
    if item.use.spEffect then
      self:addEffect('sp', item.use.spEffect)
    end
    self:addStatus(item.use.status)
    if item.use.skillType >= 0 then
      self:setType(item.use.skillType)
    end
    if item.use.targetType >= 0 then
      self:setTargetType(item.use.targetType)
    end
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
