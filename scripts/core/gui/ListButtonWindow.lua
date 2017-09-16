
--[[===============================================================================================

ListButtonWindow
---------------------------------------------------------------------------------------------------
A Button Window that has its buttons generated automatically given a list of
arbitrary elements.

=================================================================================================]]

-- Imports
local GridWindow = require('core/gui/GridWindow')
local SimpleText = require('core/gui/SimpleText')

local ListButtonWindow = class(GridWindow)

----------------------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------------------

-- Overrides GridWindow:init.
function ListButtonWindow:init(list, ...)
  self.list = list
  GridWindow.init(self, ...)
end
-- Overrides GridWindow:createButtons.
function ListButtonWindow:createButtons()
  if #self.list > 0 then
    for i = 1, #self.list do
      self:createButton(self.list[i])
    end
  end
  if self:buttonCount() == 0 then
    self:addButton('', nil, function() end)
  end
end
-- Creates a button from an element in the list.
function ListButtonWindow:createButton(element)
  -- Abstract.
end
function ListButtonWindow:createButtonInfo(button, text, fontName)
  local width = self:buttonWidth()
  if button.icon then
    local _, _, w = button.icon.sprite.quad:getViewport()
    width = width - w
  end
  local p = self:hPadding()
  fontName = fontName or 'gui_button'
  local textSprite = SimpleText(text, nil, width - p, 'right', Font[fontName])
  textSprite.sprite:setColor(Color.gui_text_default)
  button.infoText = textSprite
  button.content:add(textSprite)
end

return ListButtonWindow

