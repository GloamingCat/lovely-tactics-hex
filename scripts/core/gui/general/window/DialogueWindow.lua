
--[[===============================================================================================

DialogueWindow
---------------------------------------------------------------------------------------------------
Show a dialogue.

Message codes:
{i} = set italic
{b} = set bold
{u} = set underlined
{+x} = increases font size by x points
{-x} = decreases font size by x points
{fx} = set font (x must be a key in the globals Fonts table)
{cx} = sets the color (x must be a key in the globals Color table)
{sx} = shows sprite icon (x must be a key in the globals Icon table) [TODO]

=================================================================================================]]

-- Imports
local SimpleText = require('core/gui/widget/SimpleText')
local SimpleImage = require('core/gui/widget/SimpleImage')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')

local DialogueWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function DialogueWindow:init(GUI, w, h, x, y)
  w = w or ScreenManager.width - GUI:windowMargin()
  h = h or ScreenManager.height / 4
  x = x or (w - ScreenManager.width) / 2 + GUI:windowMargin()
  y = y or (ScreenManager.height - h) / 2 - GUI:windowMargin()
  Window.init(self, GUI, w, h, Vector(x, y))
end
-- Overrides Window:createContent.
-- Creates a simple text for dialogue.
function DialogueWindow:createContent(width, height)
  Window.createContent(self, width, height)
  self.indent = 0
  self.align = 'left'
  self.fixedIndent = 75
  local pos = Vector(-width / 2 + self:hPadding(), -height / 2 + self:vPadding())
  self.dialogue = SimpleText('', pos, width - self:hPadding() * 2, self.align, Fonts.gui_dialogue)
  self.content:add(self.dialogue)
end

---------------------------------------------------------------------------------------------------
-- Dialogue
---------------------------------------------------------------------------------------------------

-- Sets te portrait of the speaker.
-- @param(icon : table) table with id, col and row values
function DialogueWindow:setPortrait(icon)
  if self.portrait then
    self.portrait:destroy()
    self.content:removeElement(self.portrait)
  end
  self.indent = 0
  if icon and icon.id >= 0 then
    local portrait = ResourceManager:loadIcon(icon, GUIManager.renderer)
    local x, y, w, h = portrait:totalBounds()
    x = -self.width / 2 + x + w / 2
    y = self.height / 2 - h / 2
    self.portrait = SimpleImage(portrait, x, y, 1)
    self.portrait:updatePosition(self.position)
    self.content:add(self.portrait)
    self.indent = w
  end
end
-- Sets the message to be spoken.
-- @param(text : string) the rich text
function DialogueWindow:setText(text)
  self.dialogue:setMaxWidth(self.width - self:hPadding() * 2 - (self.fixedIndent or self.indent))
  self.dialogue:setAlign(self.align)
  self.dialogue:updatePosition(self.position + Vector(self.fixedIndent or self.indent, 0))
  self.dialogue:setText(text)
  self.dialogue:redraw()
end
-- Shows text
function DialogueWindow:showDialogue(text, portrait)
  self.result = nil
  self.dialogue:show()
  if portrait then
    self:setPortrait(portrait)
  end
  self:setText(text)
  self.GUI:waitForResult()
  self.dialogue:hide()
  coroutine.yield()
end

return DialogueWindow
