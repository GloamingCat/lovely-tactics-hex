
--[[===============================================================================================

SimpleText
---------------------------------------------------------------------------------------------------
A simple content element for GUI window containing just a text.
It's a type of window content.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local Sprite = require('core/graphics/Sprite')
local Text = require('core/graphics/Text')

local SimpleText = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(text : string) the text content (not rich text)
-- @param(relativePosition : Vector) position relative to its window (optional)
-- @param(width : number) the max width for texto box (optional)
-- @param(align : string) alignment inside the box (optional, left by default)
-- @param(font : string) font of the text (optional)
function SimpleText:init(text, relativePosition, width, align, font)
  assert(text, 'nil text')
  local p = { width, align or 'left', font or Fonts.gui_default }
  self.sprite = Text(text .. '', p, GUIManager.renderer)
  self.text = text
  self.relativePosition = relativePosition or Vector(0, 0, 0)
end

function SimpleText:setRelativeXYZ(x, y, z)
  local pos = self.relativePosition
  pos.x = pos.x or x
  pos.y = pos.y or y
  pos.z = pos.z or z
end
-- Changes text content (must be redrawn later).
-- @param(text : string) the new text content
function SimpleText:setText(text)
  self.text = text
end
-- Sets max width (must be redrawn later).
-- @param(w : number)
function SimpleText:setMaxWidth(w)
  self.sprite.maxWidth = w
end
-- Sets text alignment (must be redrawn later).
-- @param(align : string)
function SimpleText:setAlign(a)
  self.sprite.align = a or 'left'
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
