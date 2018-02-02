
--[[===============================================================================================

ItemWindow
---------------------------------------------------------------------------------------------------
The window that shows the list of items to be used.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local InventoryWindow = require('core/gui/general/window/InventoryWindow')
local ItemAction = require('core/battle/action/ItemAction')

-- Constants
local defaultSkillID = Config.battle.itemSkillID

local ItemWindow = class(InventoryWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function ItemWindow:init(GUI, y)
  local rowCount = 6
  local fith = rowCount * self:cellHeight() + self:vPadding() * 2
  local pos = Vector(0, y - ScreenManager.height / 2 + fith / 2)
  local items = GUI.inventory:getUsableItems(2)
  InventoryWindow.init(self, GUI, GUI.inventory, items, nil, fith, pos, rowCount)
end
-- @param(member : Battler)
function ItemWindow:setMember(member)
  self.member = member
  for i = 1, #self.matrix do
    self.matrix[i]:updateEnabled()
  end
end
-- Creates a button from an item ID.
-- @param(id : number) the item ID
function ItemWindow:createListButton(itemSlot)
  local button = InventoryWindow.createListButton(self, itemSlot)
  local id = button.item.use.skillID
  id = id >= 0 and id or defaultSkillID
  button.skill = ItemAction:fromData(id, button.item)
end

---------------------------------------------------------------------------------------------------
-- Input handlers
---------------------------------------------------------------------------------------------------

-- Called when player chooses an item.
-- @param(button : Button) the button selected
function ItemWindow:onButtonConfirm(button)
  print('use item')
  if self.result and self.result.executed and button.item.use.consume then
    self.inventory:removeItem(button.item.id)
  end
end
-- Tells if an item can be used.
-- @param(button : Button) the button to check
-- @ret(boolean)
function ItemWindow:buttonEnabled(button)
  return button.skill:canMenuUse(self.member)
end

return ItemWindow