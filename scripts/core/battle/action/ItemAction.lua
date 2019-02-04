
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
  self.item = item
  SkillAction.init(self, skillID)
  -- Effects
  for i = 1, #item.effects do
    self:addEffect(item.effects[i])
  end
  -- Status
  self:addStatus(item.statusAdd, true)
  self:addStatus(item.statusRemove, false)
  -- Type
  if item.use.skillType >= 0 then
    self:setType(item.use.skillType)
  end
  if item.use.targetType >= 0 then
    self:setTargetType(item.use.targetType)
  end
end

---------------------------------------------------------------------------------------------------
-- Item
---------------------------------------------------------------------------------------------------

-- @param(user : Battler)
function ItemAction:canExecute(user)
  return SkillAction.canExecute(self, user) and user.troop.inventory:getCount(self.item.id) > 0
end
-- @param(input : ActionInput)
-- @ret(table) results
function ItemAction:battleUse(input)
  if self.item.use.consume then
    input.user.battler.troop.inventory:removeItem(self.item.id)
  end
  return SkillAction.battleUse(self, input)
end
-- @param(input : ActionInput)
-- @ret(table) results
function ItemAction:menuUse(input)
  if self.item.use.consume then
    input.user.troop.inventory:removeItem(self.item.id)
  end
  return SkillAction.menuUse(self, input)
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
