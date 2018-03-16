
--[[===============================================================================================

GoldWindow
---------------------------------------------------------------------------------------------------
Small window that shows the troop's gold.

=================================================================================================]]

-- Imports
local SimpleImage = require('core/gui/widget/SimpleImage')
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')

-- Constants
local goldIcon = Config.icons.gold

local GoldWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides Window:createContent.
function GoldWindow:createContent(width, height)
  Window.createContent(self, width, height)
  local sprite = goldIcon.id >= 0 and ResourceManager:loadIcon(goldIcon, GUIManager.renderer)
  local icon = SimpleImage(sprite, -width / 2, -height / 2, -1, nil, height)
  self.content:add(icon)
  local pos = Vector(self:hPadding() - width / 2, self:vPadding() - height / 2, -1)
  local text = SimpleText('0', pos, width - self:hPadding() * 2, 'right', Fonts.gui_medium)
  self.content:add(text)
  self.value = text
end
-- Sets the gold value shown.
-- @param(gold : number) The current number of gold.
function GoldWindow:setGold(gold)
  self.value:setText(gold .. '')
  self.value:redraw()
end

return GoldWindow