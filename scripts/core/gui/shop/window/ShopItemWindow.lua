
--[[===============================================================================================

ShopItemWindow
---------------------------------------------------------------------------------------------------
Window with the list of items available to buy.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local ListButtonWindow = require('core/gui/ListButtonWindow')

local ShopItemWindow = class(ListButtonWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Implements ListButtonWindow:createListButton.
function ShopItemWindow:createListButton(item)
  local price = item.price
  local id = item.id
  item = Database.items[id]
  assert(item, 'Item does not exist: ' .. id)
  if not price or price < 0 then
    price = item.price
  end
  local icon = item.icon.id >= 0 and 
    ResourceManager:loadIconAnimation(item.icon, GUIManager.renderer)
  local button = Button(self)
  button:createText(item.name, 'gui_medium')
  button:createIcon(icon)
  button:createInfoText(price, 'gui_medium')
  button.item = item
  button.description = item.description
  button.price = price
  return button
end

---------------------------------------------------------------------------------------------------
-- Enable Conditions
---------------------------------------------------------------------------------------------------

-- @ret(boolean) True if at least one item of this type can be bought.
function ShopItemWindow:buttonEnabled(button)
  return self.GUI.troop.gold >= button.price
end

---------------------------------------------------------------------------------------------------
-- Confirm Callbacks
---------------------------------------------------------------------------------------------------

-- Shows the window to select the quantity.
function ShopItemWindow:onButtonConfirm(button)
  self:setVisible(false)
  self.GUI.countWindow:setItem(button.item, button.price)
  self.GUI.countWindow:setVisible(true)
  self.GUI.countWindow:activate()
end
-- Closes buy GUI.
function ShopItemWindow:onButtonCancel(button)
  --GUIManager.fiberList:fork(function()
  --  self.GUI.bonusWindow:hide()
  --end)
  self.GUI.itemWindow:hide()
  self.GUI.commandWindow:activate()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides ListButtonWindow:colCount.
function ShopItemWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function ShopItemWindow:rowCount()
  return 7
end

return ShopItemWindow