
--[[===============================================================================================

TimeWindow
---------------------------------------------------------------------------------------------------
Small window that shows the play time of the player.

=================================================================================================]]

-- Imports
local SimpleImage = require('core/gui/widget/SimpleImage')
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')

-- Constants
local icon = Config.icons.playtime

local TimeWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides Window:createContent.
function TimeWindow:createContent(width, height)
  Window.createContent(self, width, height)
  local sprite = icon and icon.id >= 0 and ResourceManager:loadIcon(icon, GUIManager.renderer)
  local icon = SimpleImage(sprite, -width / 2, -height / 2, -1, nil, height)
  self.content:add(icon)
  local pos = Vector(self:hPadding() - width / 2, self:vPadding() - height / 2, -1)
  local text = SimpleText('0', pos, width - self:hPadding() * 2, 'right', Fonts.gui_medium)
  text.sprite.alignY = 'center'
  text.sprite.maxHeight = height - self:vPadding() * 2
  self.content:add(text)
  self.text = text
end
-- Sets the time shown.
-- @param(time : number) The current play time in seconds.
function TimeWindow:setTime(time)
  time = math.floor(time)
  if not self.time or self.time ~= time then
    self.time = time
    local sec = time % 60
    local min = (time - sec) % 60
    local hour = (time - 60 * min - sec) % 60 
    self.text:setText(string.format("%02d:%02d:%02d", hour, min, sec))
    self.text:redraw()
  end
end
-- Updates play time.
function TimeWindow:update()
  Window.update(self)
  if self.open then
    self:setTime(SaveManager:playTime())
  end
end

return TimeWindow