
--[[===============================================================================================

ItemAction
---------------------------------------------------------------------------------------------------
A type of SkillAction that gets its effect from item data.

=================================================================================================]]

-- Imports
local SkillAction = require('core/battle/action/SkillAction')

local ItemAction = class(SkillAction)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides SkillAction:init.
-- Adds item effects.
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
end

---------------------------------------------------------------------------------------------------
-- Item
---------------------------------------------------------------------------------------------------

-- Overrides SkillAction:canExecute.
function ItemAction:canExecute(input)
  return SkillAction.canExecute(self, input) and input.troop.inventory:getCount(self.item.id) > 0
end
-- Overrides SkillAction:battleUse.
function ItemAction:battleUse(input)
  if self.item.consume then
    input.troop.inventory:removeItem(self.item.id)
  end
  return SkillAction.battleUse(self, input)
end
-- Overrides SkillAction:menuUse.
function ItemAction:menuUse(input)
  if self.item.consume then
    input.troop.inventory:removeItem(self.item.id)
  end
  return SkillAction.menuUse(self, input)
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Converting to string.
-- @ret(string) A string with skill's ID and name.
function ItemAction:__tostring()
  return 'ItemAction (' .. self.skillID .. ': ' .. self.data.name .. ')'
end

return ItemAction
