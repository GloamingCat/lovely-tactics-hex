
--[[===============================================================================================

LocalWindow
---------------------------------------------------------------------------------------------------
Small window that shows the location of the player.

=================================================================================================]]

-- Imports
local SimpleImage = require('core/gui/widget/SimpleImage')
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')

-- Constants
local icon = Config.icons.location

local LocalWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides Window:createContent.
function LocalWindow:createContent(width, height)
  Window.createContent(self, width, height)
  local sprite = icon and icon.id >= 0 and ResourceManager:loadIcon(icon, GUIManager.renderer)
  local icon = SimpleImage(sprite, -width / 2 + 4, -height / 2, -1, nil, height)
  self.content:add(icon)
  local pos = Vector(self:paddingX() - width / 2, self:paddingY() - height / 2, -1)
  if sprite then
    pos.x = pos.x + self:paddingX() * 2
  end
  local text = SimpleText('', pos, width - self:paddingX() * 2, 'left', Fonts.gui_medium)
  text.sprite.alignY = 'center'
  text.sprite.maxHeight = height - self:paddingY() * 2
  self.content:add(text)
  self.name = text
end
-- Sets the name shown.
-- @param(text : string) The name of the location.
function LocalWindow:setLocal(text)
  self.name:setText(text)
  self.name:redraw()
end

return LocalWindow
