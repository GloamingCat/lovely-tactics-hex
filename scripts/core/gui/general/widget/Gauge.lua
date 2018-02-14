
--[[===============================================================================================

Gauge
---------------------------------------------------------------------------------------------------
A variable meter that shows the variable state in a bar and in text.

=================================================================================================]]

-- Imports
local Bar = require('core/gui/widget/Bar')
local SimpleText = require('core/gui/widget/SimpleText')

local Gauge = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(topLeft : Vector) The position of the top left corner.
-- @param(width : number) The width of the bar.
-- @param(color : table) The color of the bar.
-- @param(x : number) Displacement of the bar (optional).
function Gauge:init(topLeft, width, color, x)
  if x then
    topLeft = topLeft:clone()
    topLeft.x = topLeft.x + x
    width = width - x
  end
  self.topLeft = topLeft
  self.width = width
  local barPos = topLeft:clone()
  barPos.y = barPos.y + 3
  barPos.z = barPos.z + 1
  self.bar = Bar(barPos, width, 6, 1)
  self.bar:setColor(color)
  self.text = SimpleText('', topLeft, width, 'right', Fonts.gui_tiny)
  self.percentage = false
end
-- Updates the value of the gauge.
-- @param(current : number) The current value.
-- @param(max : number) The maximum value.
function Gauge:setValues(current, max)
  local k = current / max
  self.bar:setValue(k)
  if self.percentage then
    self.text:setText(string.format( '%3.0f', k * 100 ) .. '%')
  else
    self.text:setText(current .. '/' .. max)
  end
  self.text:redraw()
end

---------------------------------------------------------------------------------------------------
-- Widget
---------------------------------------------------------------------------------------------------

-- Hides text and bar.
function Gauge:hide()
  self.bar:hide()
  self.text:hide()
end
-- Shows text and bar.
function Gauge:show()
  self.bar:show()
  self.text:show()
end
-- Updates bar animation.
function Gauge:update()
  self.bar:update()
end
-- Update text and bar positions.
-- @param(pos : Vector) Parent position.
function Gauge:updatePosition(pos)
  self.bar:updatePosition(pos)
  self.text:updatePosition(pos)
end
-- Destroys text and bar.
function Gauge:destroy()
  self.bar:destroy()
  self.text:destroy()
end

return Gauge