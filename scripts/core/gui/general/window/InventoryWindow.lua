
--[[===============================================================================================

InventoryWindow
---------------------------------------------------------------------------------------------------
The GUI that is open to choose an item from character's inventory.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local ListButtonWindow = require('core/gui/ListButtonWindow')
local Vector = require('core/math/Vector')

local InventoryWindow = class(ListButtonWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(GUI : GUI)
-- @param(inventory : Inventory) inventory with the list of items
-- @param(itemList : table) array with item slots that are going to be shown 
--  (all inventory's items by default)
-- @param(w : number) window's width (whole screen width by default)
-- @param(h : number) window's height (4 / 5 of the screen by default)
-- @param(pos : Vector) position of the window's center (screen center by default)
-- @param(rowCount : number) the number of visible button rows (maximum possible rows by default)
function InventoryWindow:init(GUI, inventory, itemList, w, h, pos, rowCount)
  self.inventory = inventory
  local m = GUI:windowMargin()
  w = w or ScreenManager.width - GUI:windowMargin() * 2
  h = h or ScreenManager.height * 4 / 5 - self:vPadding() * 2 - m * 3
  self.visibleRowCount = rowCount or math.floor(h / self:cellHeight())
  local fith = self.visibleRowCount * self:cellHeight() + self:vPadding() * 2
  pos = pos or Vector(0, fith / 2 - ScreenManager.height / 2 + m / 2, 0)
  ListButtonWindow.init(self, itemList or inventory, GUI, w, h, pos)
end
-- Creates a button from an item ID.
-- @param(itemSlot : table) a slot from the inventory (with item's ID and count)
-- @ret(Button)
function InventoryWindow:createListButton(itemSlot)
  local item = Database.items[itemSlot.id]
  local icon = item.icon.id >= 0 and 
    ResourceManager:loadIconAnimation(item.icon, GUIManager.renderer)
  local button = Button(self)
  button:createText(item.name, 'gui_medium')
  button:createIcon(icon)
  button:createInfoText(itemSlot.count, 'gui_medium')
  button.item = item
  button.description = item.description
  return button
end

---------------------------------------------------------------------------------------------------
-- Input handlers
---------------------------------------------------------------------------------------------------

-- Updates description when button is selected.
-- @param(button : Button)
function InventoryWindow:onButtonSelect(button)
  if self.GUI.descriptionWindow then
    self.GUI.descriptionWindow:setText(button.description)
  end
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- New col count.
function InventoryWindow:colCount()
  return 2
end
-- New row count.
function InventoryWindow:rowCount()
  return self.visibleRowCount
end
-- @ret(string) String representation (for debugging).
function InventoryWindow:__tostring()
  return 'Inventory Window'
end

return InventoryWindow
