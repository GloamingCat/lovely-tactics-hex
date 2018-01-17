
--[[===============================================================================================

ConfirmWindow
---------------------------------------------------------------------------------------------------
A window that contains "Confirm" and "Cancel" options.
result = 0 -> cancel
result = 1 -> confirm

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')

local ConfirmWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Constructor.
function ConfirmWindow:createWidgets()
  self:createButton('confirm')
  self:createButton('cancel')
end
-- Overrides GridWindow:colCount.
function ConfirmWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function ConfirmWindow:rowCount()
  return 2
end

---------------------------------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------------------------------

-- Callback for Confirm button.
function ConfirmWindow:confirmConfirm(button)
  self.result = 1
end
-- Callback for Cancel button.
function ConfirmWindow:cancelConfirm(button)
  self.result = 0
end

return ConfirmWindow
