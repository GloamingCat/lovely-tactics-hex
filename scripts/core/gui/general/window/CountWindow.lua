
--[[===============================================================================================

CountWindow
---------------------------------------------------------------------------------------------------
Window to choose a number given min/max limits.

=================================================================================================]]

-- Imports
local Spinner = require('core/gui/Spinner')
local GridWindow = require('core/gui/GridWindow')

local CountWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function CountWindow:createButtons()
  self.noCursor = true
  local spinner = Spinner(self, 1, 1, 1)
  spinner.onConfirm = self.onSpinnerConfirm
  spinner.onCancel = self.onSpinnerCancel
  self.spinner = spinner
end
-- Sets the maximum number of items (item count) that may the transfered.
-- @param(max : number) the maximum item count
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
-- Cancel transfering.
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
