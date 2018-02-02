
--[[===============================================================================================

InventoryWindow
---------------------------------------------------------------------------------------------------
The GUI that is open to choose an item from character's inventory.

=================================================================================================]]

-- Imports
local ListButtonWindow = require('core/gui/ListButtonWindow')
local Vector = require('core/math/Vector')
local Button = require('core/gui/widget/Button')

-- Constants
local defaultSkillID = Config.battle.itemSkillID

local InventoryWindow = class(ListButtonWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function InventoryWindow:init(GUI, inventory, itemList, w, h, pos)
  self.inventory = inventory
  local m = GUI:windowMargin()
  w = w or ScreenManager.width - GUI:windowMargin() * 2
  h = h or ScreenManager.height * 4 / 5 - self:vPadding() * 2 - m * 3
  self.fitRowCount = math.floor(h / self:cellHeight())
  local fith = self.fitRowCount * self:cellHeight() + self:vPadding() * 2
  pos = pos or Vector(0, fith / 2 - ScreenManager.height / 2 + m / 2, 0)
  ListButtonWindow.init(self, itemList or inventory, GUI, w, h, pos)
end
-- Creates a button from an item ID.
-- @param(id : number) the item ID
function InventoryWindow:createListButton(itemSlot)
  local item = Database.items[itemSlot.id]
  local icon = item.icon.id >= 0 and 
    ResourceManager:loadIconAnimation(item.icon, GUIManager.renderer)
  local button = Button(self)
  button:createText(item.name, 'gui_medium')
  button:createIcon(icon)
  button.item = item
  button.description = item.description
  return button
end

---------------------------------------------------------------------------------------------------
-- Input handlers
---------------------------------------------------------------------------------------------------

-- Updates description when button is selected.
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
  return self.fitRowCount
end
-- String identifier.
function InventoryWindow:__tostring()
  return 'Inventory Window'
end

return InventoryWindow
