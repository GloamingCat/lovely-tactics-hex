
local Vector = require('core/math/Vector')
local SimpleText = require('core/gui/SimpleText')
local Window = require('core/gui/Window')

local DescriptionWindow = class(Window)

function DescriptionWindow:createContent(w, h)
  Window.createContent(self, w, h)
  local x = self:hPadding() - w / 2
  local y = self:vPadding() - h / 2
  self.text = SimpleText('', Vector(x, y, -1), w - self:hPadding() * 2)
  self.content:add(self.text)
end

function DescriptionWindow:setText(t)
  self.text:setText(t)
  self.text:redraw()
end

return DescriptionWindow