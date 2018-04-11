
--[[===============================================================================================

ShopCountWindow
---------------------------------------------------------------------------------------------------
Window that shows the total price to be paidin the Shop GUI.

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
  self.noCursor = false
  CountWindow.createContent(self, ...)
  self:createValues()
  self:createIcon()
  self:createStats()
  self.spinner.confirmSound = Config.sounds.buy or self.spinner.confirmSound
end
-- Creates the texts of each gold value.
function ShopCountWindow:createValues()
  local p = self.spinner:relativePosition()
  local x, y = p.x, p.y + self:cellHeight()
  local w = self.width - self:hPadding() * 2
  local font = Fonts.gui_default
  self.current = SimpleText('', Vector(x, y, -1), w, 'right', font)
  self.decrease = SimpleText('', Vector(x, y + 13, -1), w, 'right', font)
  local line = SimpleText('__________', Vector(x, y + 17), w, 'right', font)
  self.total = SimpleText('', Vector(x, y + 30, -1), w, 'right', font)
  self.content:add(line)
  self.content:add(self.total)
  self.content:add(self.decrease)
  self.content:add(self.current)
end
-- Create the component for the item icon.
function ShopCountWindow:createIcon()
  local w = self.width - self:hPadding() * 2 - self:cellWidth()
  local h = self:cellHeight()
  local x = self:cellWidth() + self:hPadding() - self.width / 2
  local y = self:vPadding() - self.height / 2
  self.icon = SimpleImage(nil, x, y, -1, w, h)
  self.content:add(self.icon)
end
-- Creates the texts for the inventory stats (owned and equipped).
function ShopCountWindow:createStats()
  local font = Fonts.gui_medium
  local x = -self.width / 2 + self.vPadding()
  local y = self.height / 2 - 12 - self.vPadding()
  local w = self.width - self:hPadding() * 2
  self.owned = SimpleText('', Vector(x, y - 12, -1), w, 'left', font)
  self.equipped = SimpleText('', Vector(x, y, -1), w, 'left', font) 
  self.content:add(self.owned)
  self.content:add(self.equipped)
end

---------------------------------------------------------------------------------------------------
-- Item
---------------------------------------------------------------------------------------------------

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
    self.icon:setSprite(sprite)
    self.icon:updatePosition(self.position)
  else
    self.icon:setSprite(nil)
  end
  self:setPrice(gold, price)
  self:updateStats(item.id)
end
-- Updates the item price.
-- @param(gold : number) Troop's current gold.
-- @param(price : number) The price for each unit.
function ShopCountWindow:setPrice(gold, price)
  self.current:setText(gold .. '')
  self.current:redraw()
  self.decrease:setText('-' .. price)
  self.decrease:redraw()
  self.total:setText((gold - price) .. '')
  self.total:redraw()
end
-- Updates "owned" and "equipped" values.
function ShopCountWindow:updateStats(id)
  local troop = self.GUI.troop
  local owned = troop.inventory:getCount(id)
  local equipped = 0
  for i = 1, #troop.current do
    equipped = equipped + troop.current[i].equipSet:getCount(id)
  end
  for i = 1, #troop.backup do
    equipped = equipped + troop.bakcup[i].equipSet:getCount(id)
  end
  self.owned:setText(Vocab.owned .. ': ' .. (owned + equipped))
  self.equipped:setText(Vocab.equipped .. ': ' .. equipped)
  self.owned:redraw()
  self.equipped:redraw()
end

---------------------------------------------------------------------------------------------------
-- Confirm Callbacks
---------------------------------------------------------------------------------------------------

-- Confirms the buy action.
function ShopCountWindow:onSpinnerConfirm(spinner)
  local troop = self.GUI.troop
  troop.gold = troop.gold - spinner.value * self.price
  troop.inventory:addItem(self.item.id, spinner.value)
  self.GUI.goldWindow:setGold(troop.gold)
  self:returnWindow()
end
-- Cancels the buy action.
function ShopCountWindow:onSpinnerCancel(spinner)
  self:returnWindow()
end
-- Increments / decrements the quantity of items to buy.
function ShopCountWindow:onSpinnerChange(spinner)
  self:setPrice(self.GUI.troop.gold, spinner.value * self.price)
end
-- Hides this window and returns to the window with the item list.
function ShopCountWindow:returnWindow()
  local w = self.GUI.itemWindow
  for i = 1, #w.matrix do
    w.matrix[i]:updateEnabled()
    w.matrix[i]:refreshState()
  end
  w:activate()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:cellWidth.
function ShopCountWindow:cellWidth()
  return 100
end

return ShopCountWindow