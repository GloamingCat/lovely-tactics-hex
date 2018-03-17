
--[[===============================================================================================

CountWindow
---------------------------------------------------------------------------------------------------
Window to choose a number given min/max limits.

=================================================================================================]]

-- Imports
local Spinner = require('core/gui/widget/Spinner')
local GridWindow = require('core/gui/GridWindow')

local CountWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function CountWindow:init(...)
  self.noCursor = true
  self.noHighlight = true
  GridWindow.init(self, ...)
end
-- Implements GridWindow:createWidgets.
function CountWindow:createWidgets()
  local spinner = Spinner(self, 1, 1, 1)
  spinner.onConfirm = self.onSpinnerConfirm
  spinner.onCancel = self.onSpinnerCancel
  spinner.onChange = self.onSpinnerChange
  self.spinner = spinner
end
-- @param(max : number) Sets the maximum number of the spinner.
function CountWindow:setMax(max)
  self.spinner.maxValue = max
  self.spinner:setValue(1)
  self.result = nil
end

---------------------------------------------------------------------------------------------------
-- Input handlers
---------------------------------------------------------------------------------------------------

-- Confirm the number.
function CountWindow:onSpinnerConfirm(spinner)
  self.result = spinner.value
end
-- Cancel.
function CountWindow:onSpinnerCancel(spinner)
  self.result = 0
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function CountWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function CountWindow:rowCount()
  return 1
end

return CountWindow