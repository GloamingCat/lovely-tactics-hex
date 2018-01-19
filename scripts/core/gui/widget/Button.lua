
--[[===============================================================================================

Button
---------------------------------------------------------------------------------------------------
A window button. It may have a text and an animated icon.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local Sprite = require('core/graphics/Sprite')
local Animation = require('core/graphics/Animation')
local SimpleText = require('core/gui/widget/SimpleText')
local GridWidget = require('core/gui/widget/GridWidget')

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
function Button:init(window, onConfirm, enableCondition)
  GridWidget.init(self, window)
  self.onConfirm = onConfirm or window.onButtonConfirm or self.onConfirm
  self.onCancel = window.onButtonCancel or self.onCancel
  self.onSelect = window.onButtonSelect or self.onSelect
  self.onMove = window.onButtonMove or self.onMove
  self.enableCondition = enableCondition or window.buttonEnabled or self.enableCondition
  self.confirmSound = Config.sounds.buttonConfirm
  self.cancelSound = Config.sounds.buttonCancel
  self.selectSound = Config.sounds.buttonSelect
end
-- Creates a buttons for the action represented by the given key.
-- @param(window : GridWindow) the window that this button is component of
-- @param(key : string) action's key
-- @ret(Button)
function Button:fromKey(window, key)
  local button = self(window, window[key .. 'Confirm'], window[key .. 'Enabled'])
  local icon = Icons[key]
  if icon then
    button:createIcon(icon)
  end
  local text = Vocab[key]
  if text then
    button:createText(text)
  end
  return button
end
-- @param(text : string) the text shown in the button
-- @param(fontName : string) the text's font, from Fonts folder (optional, uses default)
function Button:createText(name, fontName, align, w, pos)
  if self.text then
    self.text:destroy()
  end
  fontName = fontName or 'gui_button'
  w = (w or self.window:cellWidth()) - self:iconWidth()
  pos = pos or Vector(0, 0, 0)
  local text = SimpleText(name, pos, w, align or 'left', Fonts[fontName])
  text.sprite.alignY = 'center'
  text.sprite.maxHeight = self.window:cellHeight()
  text.sprite:setColor(Color.gui_text_enabled)
  self.text = text
  self.content:add(text)
  return self.text
end
-- @param(info : string) the auxiliar info text in the right side of the button
-- @param(fontName : string) the text's font, from Fonts folder (optional, uses default)
function Button:createInfoText(info, fontName, align, w, pos)
  if self.infoText then
    self.infoText:destroy()
  end
  local bw = self.window:cellWidth() - self:iconWidth()
  w = w or bw
  pos = pos or Vector(bw - w - 2, 0, 0)
  fontName = fontName or 'gui_button'
  local text = SimpleText(info, pos, w, align or 'right', Fonts[fontName])
  text.sprite.alignY = 'center'
  text.sprite.maxHeight = self.window:cellHeight()
  text.sprite:setColor(Color.gui_text_enabled)
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
    icon = Animation:fromImage(img, GUIManager.renderer)
  end
  icon.sprite:setColor(Color.gui_icon_enabled)
  self.icon = icon
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
  local name = self.enabled and 'enabled' or 'disabled'
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
    self.icon.sprite:setXYZ(0, 0)
    local x, y, w, h = self.icon.sprite:totalBounds()
    self.icon.sprite:setXYZ(pos.x - x, pos.y + self.window:cellHeight() / 2, pos.z)
    pos:add(Vector(w, 0))
  end
  for i = 1, #self.content do
    local c = self.content[i]
    if c.updatePosition then
      c:updatePosition(pos)
    end
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
