
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

-- Alias
local deltaTime = love.timer.getDelta
local round = math.round
local yield = coroutine.yield

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
  self.textSpeed = 40
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

function DialogueWindow:cutText(text, time)
  local i = 0
  for textFragment, resourceKey in text:gmatch('([^{]*){(.-)}') do
    if time <= #textFragment then
      return text:sub(1, round(time) + i)
    else
      time = time - #textFragment
      i = i + #textFragment + #resourceKey + 2
    end
  end
  local textFragment = text:match('[^}]+$')
  if textFragment then
    if time <= #textFragment then
      return text:sub(1, round(time) + i)
    end
  end
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
  local char = nil
  if icon and not icon.id then
    char = Database.characters[icon.charID]
    icon = char.portraits[icon.name]
  end
  if icon and icon.id >= 0 then
    local portrait = ResourceManager:loadIcon(icon, GUIManager.renderer)
    if char then
      portrait:applyTransformation(char.transform)
    end
    portrait:setOffset(0, 0)
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
function DialogueWindow:rollText(text)
  self.dialogue:setMaxWidth(self.width - self:hPadding() * 2 - (self.fixedIndent or self.indent))
  self.dialogue:setAlign(self.align)
  self.dialogue:updatePosition(self.position + Vector(self.fixedIndent or self.indent, 0))
  local time = 0
  while true do
    if InputManager.keys['confirm']:isTriggered() then
      yield()
      break
    end
    time = time + deltaTime() * self.textSpeed 
    local subText = self:cutText(text, time)
    if not subText then
      break
    end
    self.dialogue:setText(subText)
    self.dialogue:redraw()
    yield()
  end
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
  self:rollText(text)
  self.GUI:waitForResult()
  yield()
end

return DialogueWindow