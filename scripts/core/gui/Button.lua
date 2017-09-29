
--[[===============================================================================================

Button
---------------------------------------------------------------------------------------------------
A window button. It may have a text and an animated icon.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local Sprite = require('core/graphics/Sprite')
local Animation = require('core/graphics/Animation')
local SimpleText = require('core/gui/SimpleText')
local GridWidget = require('core/gui/GridWidget')

local Button = class(GridWidget)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(window : GridWindow) the window that this button is component of
-- @param(onConfirm : function) the function called when player confirms (optinal)
-- @param(onSelects : function) the function called when player selects this button (optinal)
-- @param(enableCondition : function) the function that tells if 
--  this button is enabled (optional)
-- @param(onMove : function) the function called when player presses arrows (optinal)
function Button:init(window, onConfirm, onSelect, enableCondition, onMove)
  GridWidget.init(self, window)
  self.onConfirm = onConfirm or self.onConfirm 
  self.onSelect = onSelect or self.onSelect
  self.enableCondition = enableCondition or self.enableCondition
  self.onMove = onMove or self.onMove
end
-- @param(text : string) the text shown in the button
-- @param(fontName : string) the text's font, from Fonts folder (optional, uses default)
function Button:createText(text, fontName, align, w, pos)
  if self.text then
    self.text:destroy()
  end
  fontName = fontName or 'gui_button'
  w = (w or self.window:buttonWidth()) - self:iconWidth()
  pos = pos or Vector(0, 1, 0)
  self.text = SimpleText(text, pos, w, align or 'left', Font[fontName])
  self.text.sprite:setColor(Color.gui_text_default)
  self.content:add(self.text)
  return self.text
end
-- @param(info : string) the auxiliar info text in the right side of the button
-- @param(fontName : string) the text's font, from Fonts folder (optional, uses default)
function Button:createInfoText(info, fontName, align, w, pos)
  if self.infoText then
    self.infoText:destroy()
  end
  local bw = self.window:buttonWidth() - self:iconWidth()
  w = w or bw
  pos = pos or Vector(bw - w, 1, 0)
  fontName = fontName or 'gui_button'
  local text = SimpleText(info, pos, w, align or 'right', Font[fontName])
  text.sprite:setColor(Color.gui_text_default)
  self.infoText = text
  self.content:add(text)
  return text
end
-- @param(icon : Animation | string) the icon graphics or the path to the icon
function Button:createIcon(icon)
  if not icon then
    return
  end
  if type(icon) == 'string' then
    local img = love.graphics.newImage('images/' .. icon)
    icon = Animation.fromImage(img, GUIManager.renderer)
  end
  self.icon = icon
  icon.sprite:setColor(Color.gui_icon_default)
  self.content:add(icon)
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- @ret(number)
function Button:iconWidth()
  if self.icon then
    local _, _, w = self.icon.sprite.quad:getViewport()
    return w
  else
    return 0
  end
end
-- @param(text : string)
function Button:setText(text)
  self.text:setText(text)
  self.text:redraw()
end
-- @param(text : string)
function Button:setInfoText(text)
  self.infoText:setText(text)
  self.infoText:redraw()
end
-- Converting to string.
function Button:__tostring()
  if not self.text then
    return '' .. self.index
  end
  return self.index .. ': ' .. self.text.text
end

---------------------------------------------------------------------------------------------------
-- Input handlers
---------------------------------------------------------------------------------------------------

-- Called when player presses "Confirm" on this button.
function Button.onConfirm(window, button)
  window.result = button.index
end
-- Called when player presses "Cancel" on this button.
function Button.onCancel(window, button)
  window.result = 0
end

---------------------------------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------------------------------

-- Updates text and icon color based on button state.
function Button:updateColor()
  local name = 'disabled'
  if self.enabled then
    if self.selected then
      name = 'highlight'
    else
      name = 'default'
    end
  end
  if self.text then
    local color = Color['gui_text_' .. name]
    self.text.sprite:setColor(color)
  end
  if self.infoText then
    local color = Color['gui_text_' .. name]
    self.infoText.sprite:setColor(color)
  end
  if self.icon then
    local color = Color['gui_icon_' .. name]
    self.icon.sprite:setColor(color)
  end
end
-- Enables/disables this button.
-- @param(value : boolean) true to enable, false to disable
function Button:setEnabled(value)
  if value ~= self.enabled then
    self.enabled = value
    self:updateColor()
  end
end
-- Selects/deselects this button.
-- @param(value : boolean) true to select, false to deselect
function Button:setSelected(value)
  if value ~= self.selected then
    self.selected = value
    if self.enabled then
      self:updateColor()
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Position
---------------------------------------------------------------------------------------------------

-- Updates position based on window's position.
function Button:updatePosition(windowPos)
  local pos = self:relativePosition()
  pos:add(windowPos)
  if self.icon then
    self.icon.sprite:setPosition(pos)
    local x, y, w, h = self.icon.sprite:totalBounds()
    self.icon.sprite:setXYZ(nil, pos.y + (self.window:buttonHeight() - h) / 2)
    pos:add(Vector(w - (self.icon.sprite.position.x - x), 0))
  end
  if self.text then
    self.text:updatePosition(pos)
  end
  if self.infoText then
    self.infoText:updatePosition(pos)
  end
end

---------------------------------------------------------------------------------------------------
-- Show/hide
---------------------------------------------------------------------------------------------------

-- Shows button's text and icon.
function Button:show()
  if self.col < self.window.offsetCol + 1 then
    return
  elseif self.row < self.window.offsetRow + 1 then
    return
  elseif self.col > self.window.offsetCol + self.window:colCount() then
    return
  elseif self.row > self.window.offsetRow + self.window:rowCount() then
    return
  end
  if self.enableCondition then
    local enabled = self.enableCondition(self.window, self)
    if not enabled then
      self:setEnabled(false)
    end
  end
  GridWidget.show(self)
end

return Button
