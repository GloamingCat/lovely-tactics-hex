
--[[===============================================================================================

SpinnerButton
---------------------------------------------------------------------------------------------------

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWidget = require('core/gui/widget/GridWidget')
local Spinner = require('core/gui/widget/Spinner')

local SpinnerButton = class(Spinner, Button)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(window  : GridWindow) the window this spinner belongs to.
-- @param(minValue : number) Minimum value.
-- @param(maxValue : number) Maximum value.
-- @param(initValue : number) Initial value.
function SpinnerButton:init(window, maxValue, minValue, initValue)
  Button.init(self, window)
  self.minValue = minValue or -math.huge
  self.maxValue = maxValue or math.huge
  local w = self.window:cellWidth() / 2
  self:initContent(initValue or 0, w, self.window:cellHeight() / 2, w)
end
-- Creates a button for the action represented by the given key.
-- @param(window : GridWindow) the window that this button is component of
-- @param(key : string) action's key
-- @ret(SpinnerButton)
function SpinnerButton:fromKey(window, key, maxValue, minValue, initValue)
  local button = self(window, maxValue, minValue, initValue)
  local icon = Icons[key]
  if icon then
    button:createIcon(icon)
  end
  local text = Vocab[key]
  if text then
    button:createText(text)
  end
  button.onConfirm = window[key .. 'Confirm'] or button.onConfirm
  button.onChange = window[key .. 'Change'] or button.onChange
  button.key = key
  return button
end

return SpinnerButton