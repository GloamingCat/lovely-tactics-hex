
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
local SimpleText = require('core/gui/SimpleText')
local SimpleImage = require('core/gui/SimpleImage')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')

local DialogueWindow = class(Window)

function DialogueWindow:init(GUI, w, h, pos)
  w = w or ScreenManager.width - GUI:windowMargin()
  h = h or ScreenManager.height / 4
  pos = pos or Vector(0, (ScreenManager.height - h) / 2 - GUI:windowMargin())
  Window.init(self, GUI, w - self:hPadding() * 2, h, pos)
end

function DialogueWindow:createContent(width, height)
  Window.createContent(self, width, height)
  self.indent = 0
  self.align = 'left'
  local pos = Vector(-width / 2 + self:hPadding(), -height / 2 + self:vPadding())
  self.dialogue = SimpleText('', pos, width, self.align, Fonts.gui_dialogue)
  self.content:add(self.dialogue)
end

function DialogueWindow:setPortrait(icon)
  if self.portrait then
    self.portrait:destroy()
    self.content:removeElement(self.portrait)
  end
  self.indent = 0
  if icon and icon.id >= 0 then
    local portrait = ResourceManager:loadIcon(icon, GUIManager.renderer)
    local x, y, w, h = portrait:totalBounds()
    x = -self.width / 2 - x
    y = self.height / 2 - y - h
    self.portrait = SimpleImage(portrait, x, y, 1)
    self.content:add(self.portrait)
    self.indent = w
  end
end

function DialogueWindow:setText(text)
  self.dialogue:setMaxWidth(self.width - self:hPadding() * 2 - self.indent)
  self.dialogue:setAlign(self.align)
  self.dialogue:updatePosition(self.position + Vector(self.indent, 0))
  self.dialogue:setText(text)
  self.dialogue:redraw()
end

function DialogueWindow:showDialogue(text, portrait)
  self.result = nil
  self.dialogue:show()
  self:setText(text)
  self.GUI:waitForResult()
  self.dialogue:hide()
  coroutine.yield()
end

return DialogueWindow
