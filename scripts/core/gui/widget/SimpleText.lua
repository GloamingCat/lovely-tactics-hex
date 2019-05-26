
--[[===============================================================================================

SimpleText
---------------------------------------------------------------------------------------------------
A simple content element for GUI window containing just a text.
It's a type of window content.

=================================================================================================]]

-- Imports
local Sprite = require('core/graphics/Sprite')
local Text = require('core/graphics/Text')
local Vector = require('core/math/Vector')

local SimpleText = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(text : string) The text content (not rich text).
-- @param(relativePosition : Vector) Position relative to its window (optional).
-- @param(width : number) The max width for texto box (optional).
-- @param(align : string) Alignment inside the box (optional, left by default).
-- @param(font : string) Font of the text (optional).
function SimpleText:init(text, relativePosition, width, align, font)
  assert(text, 'nil text')
  local p = { width, align or 'left', font or Fonts.gui_default }
  self.sprite = Text(text .. '', p, GUIManager.renderer)
  self.text = text
  self.relativePosition = relativePosition or Vector(0, 0, 0)
end
-- Sets the position relative to window's center.
-- @param(x : number) Pixel x.
-- @param(y : number) Pixel y.
-- @param(z : number) Depth.
function SimpleText:setRelativeXYZ(x, y, z)
  local pos = self.relativePosition
  pos.x = pos.x or x
  pos.y = pos.y or y
  pos.z = pos.z or z
end
-- Changes text content (must be redrawn later).
-- @param(text : string) The new text content.
function SimpleText:setText(text)
  self.text = text
end
-- Sets max width (must be redrawn later).
-- @param(w : number)
function SimpleText:setMaxWidth(w)
  self.sprite.maxWidth = w
end
-- Sets max height (must be redrawn later).
-- @param(h : number)
function SimpleText:setMaxHeight(h)
  self.sprite.maxHeight = h
end
-- Sets text alignment (must be redrawn later).
-- @param(h : string) Horizontal alignment.
-- @param(v : string) Vertical alignment.
function SimpleText:setAlign(h, v)
  self.sprite.alignX = h or 'left'
  self.sprite.alignY = v or 'top'
end
-- Redraws text.
function SimpleText:redraw()
  self.sprite:setText(self.text)
end

---------------------------------------------------------------------------------------------------
-- Window Content methods
---------------------------------------------------------------------------------------------------

-- Hides text.
function SimpleText:show()
  self.sprite:setVisible(true)
end
-- Shows text.
function SimpleText:hide()
  self.sprite:setVisible(false)
end
-- Sets position relative to its parent window.
-- @param(pos : Vector) window position
function SimpleText:updatePosition(pos)
  local rpos = self.relativePosition
  self.sprite:setXYZ(pos.x + rpos.x, pos.y + rpos.y, pos.z + rpos.z)
end
-- Removes text.
function SimpleText:destroy()
  self.sprite:destroy()
end

return SimpleText
