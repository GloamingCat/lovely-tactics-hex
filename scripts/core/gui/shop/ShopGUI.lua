
--[[===============================================================================================

ShopGUI
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Imports
local DescriptionWindow = require('core/gui/general/window/DescriptionWindow')
local GoldWindow = require('core/gui/general/window/GoldWindow')
local GUI = require('core/gui/GUI')
--local ShopBonusWindow = require('core/gui/shop/window/ShopBonusWindow')
local ShopCommandWindow = require('core/gui/shop/window/ShopCommandWindow')
--local ShopCountWindow = require('core/gui/shop/window/ShopCountWindow')
--local ShopItemWindow = require('core/gui/shop/window/ShopItemWindow')
local Troop = require('core/battle/Troop')
local Vector = require('core/math/Vector')

local ShopGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(items : table) Array of items to be sold.
-- @param(sell : boolean) True if the player can sell anything here.
function ShopGUI:init(items, sell, troop)
  self.troop = troop or Troop()
  self.items = items
  self.sell = sell
  GUI.init(self)
end
-- Implements GUI:createWindow.
function ShopGUI:createWindows()
  self:createCommandWindow()
  self:createGoldWindow()
  --self:createItemWindow()
  --self:createCountWindow()
  --self:createBonusWindow()
  --self:createDescriptionWindow()
  self:setActiveWindow(self.commandWindow)
end
function ShopGUI:createCommandWindow()
  local window = ShopCommandWindow(self, #self.items > 0, self.sell)
  local x = window.width / 2 - ScreenManager.width / 2 + self:windowMargin()
  local y = window.height / 2 - ScreenManager.height / 2 + self:windowMargin()
  window:setXYZ(x, y)
  self.commandWindow = window
end
function ShopGUI:createGoldWindow()
  local width = ScreenManager.width - self.commandWindow.width - self:windowMargin() * 3
  local height = self.commandWindow.height
  local x = ScreenManager.width / 2 - self:windowMargin() - width / 2
  local y = self.commandWindow.position.y
  self.goldWindow = GoldWindow(self, width, height, Vector(x, y))
  self.goldWindow:setGold(self.troop.gold)
end
function ShopGUI:createItemWindow()
  local window = ShopItemWindow(self, self.items)
  local x = window.width / 2 - ScreenManager.width / 2
  local y = window.height / 2 - ScreenManager.height / 2 +
    self.commandWindow.height + self:windowMargin() * 2
  window:setXYZ(x, y)
  self.itemWindow = window
end
function ShopGUI:createCountWindow()
  local window = self.itemwindow
  self.countWindow = ShopCountWindow(self, window.width, window.height, window.position)
end
function ShopGUI:createBonusWindow()
  local width = ScreenManager.width - self.itemWindow.width - self:windowMargin() * 3
  local height = self.itemWindow.height
  local x = ScreenManager.width / 2 - self:windowMargin()
  local y = self.itemWindow.position.y
  self.bonusWindow = ShopBonusWindow(self, width, height, Vector(x, y))
end
function ShopGUI:createDescriptionWindow()
  local width = ScreenManager.width - self:windowMargin() * 2
  local height = ScreenManager.height - self:windowMargin() * 3 - 
    self.commandWindow.height - self.itemWindow.height
  local y = ScreenManager.height / 2 - height / 2 - self:windowMargin()
  self.descriptionWindow = DescriptionWindow(self, width, height, Vector(0, y))
end

return ShopGUI