
--[[===============================================================================================

ShopCommandWindow
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')

local ShopCommandWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(GUI : GUI) Parent GUI.
-- @param(buy : boolean) True if "buy" option if enabled.
-- @param(sell : boolean) True if "sell" option if enabled.
function ShopCommandWindow:init(GUI, buy, sell)
  self.buy = buy
  self.sell = sell
  GridWindow.init(self, GUI)
end
-- Implements GridWindow:createWidgets.
function ShopCommandWindow:createWidgets()
  Button:fromKey(self, 'buy')
  Button:fromKey(self, 'sell')
end

---------------------------------------------------------------------------------------------------
-- Confirm Callbacks
---------------------------------------------------------------------------------------------------

function ShopCommandWindow:buyConfirm()
  
end

function ShopCommandWindow:sellConfirm()
  
end

---------------------------------------------------------------------------------------------------
-- Enable Conditions
---------------------------------------------------------------------------------------------------

-- Enable condition of "buy" button.
function ShopCommandWindow:buyEnabled()
  return self.buy
end
-- Enable condition of "sell" button.
function ShopCommandWindow:sellEnabled()
  return self.sell 
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

function ShopCommandWindow:colCount()
  return 2
end

function ShopCommandWindow:rowCount()
  return 1
end

return ShopCommandWindow