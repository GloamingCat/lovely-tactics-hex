
--[[===============================================================================================

DescriptionWindow
---------------------------------------------------------------------------------------------------
A window that shows a description text.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local SimpleText = require('core/gui/widget/SimpleText')
local Window = require('core/gui/Window')

local DescriptionWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(w : number) window's total width
-- @param(h : number) window's total height
function DescriptionWindow:createContent(w, h)
  Window.createContent(self, w, h)
  local x = self:hPadding() - w / 2
  local y = self:vPadding() - h / 2
  self.text = SimpleText('', Vector(x, y, -1), w - self:hPadding() * 2, 'left', Fonts.gui_medium)
  self.content:add(self.text)
end
-- Sets text to be shown.
-- @param(txt : string)
function DescriptionWindow:setText(txt)
  self.text:setText(txt)
  self.text:redraw()
end
-- @ret(string) string representation (for debugging)
function DescriptionWindow:__tostring()
  return 'Description Window'
end

return DescriptionWindow