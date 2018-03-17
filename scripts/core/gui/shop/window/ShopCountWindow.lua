
--[[===============================================================================================

ShopCountWindow
---------------------------------------------------------------------------------------------------

=================================================================================================]]

-- Imports
local CountWindow = require('core/gui/general/window/CountWindow')
local SimpleImage = require('core/gui/widget/SimpleImage')
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')

local ShopCountWindow = class(CountWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:createContent. Creates the text with the price values.
function ShopCountWindow:createContent(...)
  CountWindow.createContent(self, ...)
  local x = self:hPadding() - self.width / 2
  local y = self.height / 2 - self:vPadding()
  local w = self.width - self:hPadding() * 2
  local font = Fonts.gui_default
  self.total = SimpleText('C', Vector(x, y - 15, -1), w, 'right', font)
  local line = SimpleText('__________', Vector(x, y - 28), w, 'right', font)
  self.decrease = SimpleText('B', Vector(x, y - 32, -1), w, 'right', font)
  self.current = SimpleText('A', Vector(x, y - 45, -1), w, 'right', font)
  self.content:add(line)
  self.content:add(self.total)
  self.content:add(self.decrease)
  self.content:add(self.current)
  self.spinner.confirmSound = Config.sounds.buy or self.spinner.confirmSound
end
-- Sets the current item type to buy.
-- @param(item : table) The item's data from database.
-- @param(price : number) The price for each unit.
function ShopCountWindow:setItem(item, price)
  local gold = self.GUI.troop.gold
  self.price = price
  self.item = item
  self:setMax(math.floor(gold / price))
  if item.icon and item.icon.id >= 0 then
    local sprite = ResourceManager:loadIcon(item.icon, GUIManager.renderer)
    local w = self.width - self:hPadding() * 2 - self:cellWidth()
    local h = self:cellHeight()
    local x = self:cellWidth() + self:hPadding() - self.width / 2
    local y = self:vPadding() - self.height / 2
    self.icon = SimpleImage(sprite, x, y, -1, w, h)
    self.content:add(self.icon)
  end
  self:setTexts(gold, price)
end

function ShopCountWindow:setTexts(gold, price)
  self.current:setText(gold .. '')
  self.current:redraw()
  self.decrease:setText('-' .. price)
  self.decrease:redraw()
  self.total:setText((gold - price) .. '')
  self.total:redraw()
end

---------------------------------------------------------------------------------------------------
-- Confirm Callbacks
---------------------------------------------------------------------------------------------------

function ShopCountWindow:onSpinnerConfirm(spinner)
  local troop = self.GUI.troop
  troop.gold = troop.gold - spinner.value * self.price
  troop.inventory:addItem(self.item.id, spinner.value)
  self.GUI.goldWindow:setGold(troop.gold)
  self:returnWindow()
end
function ShopCountWindow:onSpinnerCancel(spinner)
  self:returnWindow()
end
function ShopCountWindow:onSpinnerChange(spinner)
  self:setTexts(self.GUI.troop.gold, spinner.value * self.price)
end
-- Hides this window and returns to the window with the item list.
function ShopCountWindow:returnWindow()
  self:setVisible(false)
  self.GUI.itemWindow:setVisible(true)
  self.GUI.itemWindow:activate()
  if self.icon then
    self.icon:destroy()
    self.content:removeElement(self.icon)
  end
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:cellWidth.
function ShopCountWindow:cellWidth()
  return 100
end

return ShopCountWindow