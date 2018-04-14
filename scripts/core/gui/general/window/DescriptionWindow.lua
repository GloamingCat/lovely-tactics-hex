
--[[===============================================================================================

DescriptionWindow
---------------------------------------------------------------------------------------------------
A window that shows a description text.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local SimpleText = require('core/gui/widget/SimpleText')
local Window = require('core/gui/Window')

-- Alias
local round = math.round

local DescriptionWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(w : number) window's total width
-- @param(h : number) window's total height
function DescriptionWindow:createContent(w, h)
  Window.createContent(self, w, h)
  local x = self:paddingX() - w / 2
  local y = self:paddingY() - h / 2
  self.text = SimpleText('', Vector(x, y, -1), w - self:paddingX() * 2, 'left', Fonts.gui_medium)
  self.content:add(self.text)
end
-- Sets text to be shown.
-- @param(txt : string)
function DescriptionWindow:setText(txt)
  self.text:setText(txt or '')
  self.text:redraw()
end
-- Gets the text the is being shown in the window.
-- @ret(string) The text as string.
function DescriptionWindow:getText()
  return self.text.sprite.text
end
-- Resizes the window to the minimum size that includes the text.
function DescriptionWindow:packText()
  local w, h = self.text.sprite:quadBounds()
  w, h = round(w), round(h)
  self.text.relativePosition = Vector(-w / 2, -h / 2, -1)
  self:resize(w + self:paddingX() * 2, h + self:paddingY() * 2)
end
-- @ret(string) String representation (for debugging).
function DescriptionWindow:__tostring()
  return 'Description Window'
end

return DescriptionWindow