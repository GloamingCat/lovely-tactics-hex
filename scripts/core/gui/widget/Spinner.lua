
--[[===============================================================================================

Spinner
---------------------------------------------------------------------------------------------------
A spinner for choosing a numeric value.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local Sprite = require('core/graphics/Sprite')
local SimpleText = require('core/gui/widget/SimpleText')
local SimpleImage = require('core/gui/widget/SimpleImage')
local GridWidget = require('core/gui/widget/GridWidget')

-- Alias
local Image = love.graphics.newImage

local Spinner = class(GridWidget)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(window  : GridWindow) the window this spinner belongs to.
-- @param(minValue : number) Minimum value.
-- @param(maxValue : number) Maximum value.
-- @param(initValue : number) Initial value.
function Spinner:init(window, minValue, maxValue, initValue)
  self.enabled = true
  GridWidget.init(self, window)
  self.clickSound = nil
  self.onConfirm = self.onConfirm or window.onSpinnerConfirm
  self.onCancel = self.onCancel or window.onSpinnerCancel
  self.onChange = self.onChange or window.onSpinnerChange
  self.minValue = minValue or -math.huge
  self.maxValue = maxValue or math.huge
  self:initContent(initValue or 0, self.window:cellWidth(), self.window:cellHeight() / 2)
end
-- Creates arrows and value test.
function Spinner:initContent(initValue, w, h, x, y)
  x, y = x or 0, y or 0
  -- Left arrow icon
  local leftArrow = Image('images/GUI/Spinner/leftArrow.png')
  local leftArrowSprite = Sprite(GUIManager.renderer, leftArrow)
  leftArrowSprite:setQuad()
  self.leftArrow = SimpleImage(leftArrowSprite, 
    x + leftArrow:getWidth() / 2, 
    y + h - leftArrow:getHeight() / 2)
  -- Right arrow icon
  local rightArrow = Image('images/GUI/Spinner/rightArrow.png')
  local rightArrowSprite = Sprite(GUIManager.renderer, rightArrow)
  rightArrowSprite:setQuad()
  self.rightArrow = SimpleImage(rightArrowSprite, 
    x + w - rightArrow:getWidth() / 2, 
    y + h - rightArrow:getHeight() / 2)
  -- Value text in the middle
  self.value = initValue
  local textPos = Vector(x + leftArrow:getWidth(), y)
  local textWidth = w - leftArrow:getWidth() - rightArrow:getWidth() 
  self.valueText = SimpleText('' .. initValue, textPos, textWidth, 'center', Fonts.gui_button)
  -- Add to content list
  self.content:add(self.leftArrow)
  self.content:add(self.rightArrow)
  self.content:add(self.valueText)
  -- Bounds
  self.width = w
  self.height = h
  self.x = x
  self.y = y
end

---------------------------------------------------------------------------------------------------
-- Input Handlers
---------------------------------------------------------------------------------------------------

-- Called when player presses arrows on this spinner.
function Spinner.onMove(window, self, dx, dy)
  self:changeValue(dx, dy)
end
-- Called when player presses a mouse button.
function Spinner.onClick(window, self, x, y)
  local pos = self:relativePosition()
  x, y = x - pos.x, y - pos.y
  if x < self.x or y < self.y or x > self.width + self.x then
    return
  end
  if x <= self.x + self.width / 4 then
    self:changeValue(-1, 0)
  elseif x >= self.width * 3 / 4 + self.x then
    self:changeValue(1, 0)
  else
    return
  end
  if self.confirmSound then
    AudioManager:playSFX(self.confirmSound)
  end
end

---------------------------------------------------------------------------------------------------
-- Value
---------------------------------------------------------------------------------------------------

-- Changes the current value according to input.
-- @param(dx : number) Input axis X.
-- @param(dy : number) Input axis Y.
function Spinner:changeValue(dx, dy)
  if self.bigIncrement and InputManager.keys['dash']:isPressing() then
    dx = dx * self.bigIncrement
  end
  local value = math.min(self.maxValue, math.max(self.minValue, self.value + dx))
  if self.enabled then
    self:setValue(value)
    if self.onChange then
      self.onChange(self.window, self)
    end
    if self.selectSound then
      AudioManager:playSFX(self.selectSound)
    end
  end
end
-- Changes the current value.
-- @param(value : number) new value, assuming it is inside limit bounds
function Spinner:setValue(value)
  if self.value ~= value then
    self.value = value
    self.valueText:setText(value .. '')
    self.valueText:redraw()
  end
end

return Spinner