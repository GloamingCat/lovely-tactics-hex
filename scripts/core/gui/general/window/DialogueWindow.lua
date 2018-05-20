
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
local DescriptionWindow = require('core/gui/general/window/DescriptionWindow')
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

-- @param(GUI : GUI) Parent GUI.
-- @param(w : number) Width of the window.
-- @param(h : number) Height of the window.
-- @param(x : number) Pixel x of the window.
-- @param(y : number) Pixel y of the window.
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
  self.textSpeed = 40
  self.textSound = Config.sounds.text
  self.soundFrequence = 4
  self.indent = 0
  self.align = 'left'
  self.fixedIndent = 75
  local pos = Vector(-width / 2 + self:paddingX(), -height / 2 + self:paddingY())
  self.dialogue = SimpleText('', pos, width - self:paddingX() * 2, self.align, Fonts.gui_dialogue)
  self.dialogue.sprite.wrap = true
  self.content:add(self.dialogue)
  self.nameWindow = DescriptionWindow(self.GUI, 80, 24)
  self.nameWindow:setVisible(false)
end

---------------------------------------------------------------------------------------------------
-- Dialogue
---------------------------------------------------------------------------------------------------

-- @ret(boolean) True if player pressed the button to pass the dialogue.
function DialogueWindow:buttonPressed()
  return InputManager.keys['confirm']:isTriggered() or InputManager.keys['cancel']:isTriggered() 
    or InputManager.keys['mouse1']:isTriggered() or InputManager.keys['mouse2']:isTriggered()
end
-- [COROUTINE] Shows a message and waits until player presses the confirm button.
-- @param(text : string) The message.
-- @param(portrait : table) The speaker's portrait icon (optional).
function DialogueWindow:showDialogue(text, portrait, name)
  self.dialogue:show()
  if portrait then
    self:setPortrait(portrait)
  end
  if name then
    self:setName(name)
  end
  self:rollText(text)
  self.GUI:waitForResult()
  self.result = nil
  yield()
end
-- Shows text character by character.
-- @param(text : string) The message.
function DialogueWindow:rollText(text)
  self.dialogue:setMaxWidth(self.width - self:paddingX() * 2 - (self.fixedIndent or self.indent))
  self.dialogue:setAlign(self.align)
  self.dialogue.sprite:setText(text)
  self.dialogue:updatePosition(self.position + Vector(self.fixedIndent or self.indent, 0))
  local time, soundTime = 0, self.soundFrequence
  while true do
    if self.textSound and soundTime >= self.soundFrequence then
      soundTime = soundTime - self.soundFrequence
      AudioManager:playSFX(self.textSound)
    end
    if self:buttonPressed() then
      yield()
      break
    end
    time = time + deltaTime() * self.textSpeed
    soundTime = soundTime + deltaTime() * self.textSpeed
    if time >= self.dialogue.sprite.parsedLines.length then
      break
    end
    self.dialogue.sprite.cutPoint = math.ceil(time)
    self.dialogue.sprite:redrawBuffers()
    yield()
  end
  self.dialogue.sprite.cutPoint = nil
  self.dialogue.sprite:redrawBuffers()
end

---------------------------------------------------------------------------------------------------
-- Speaker
---------------------------------------------------------------------------------------------------

-- Shows the portrait of the speaker.
-- @param(icon : table) Table with id, col and row values.
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
    self.portrait = SimpleImage(portrait, x - w / 2, y - h / 2, 1)
    self.portrait:updatePosition(self.position)
    self.content:add(self.portrait)
    self.indent = w
  end
end
-- Shows the name of the speaker.
-- @param(text : string) Nil or empty to hide window, any other string to show.
function DialogueWindow:setName(text)
  if text and text ~= '' then
    self.nameWindow:setText(text)
    self.nameWindow:packText()
    local nameX = - self.width / 2 + self.position.x + self.fixedIndent + 10
    local nameY = - self.height / 2 + self.position.y + self:paddingY() / 2
    self.nameWindow:setVisible(true)
    self.nameWindow:setXYZ(nameX + self.nameWindow.width / 2,
      nameY - self.nameWindow.height / 2, -5)
  else
    self.nameWindow:setVisible(false)
  end
end
-- Overrides Window:hideContent to hide name window.
function DialogueWindow:hideContent(...)
  self.nameWindow:setVisible(false)
  Window.hideContent(self, ...)
end
-- Called when player presses a mouse button.
function DialogueWindow:onClick(button, x, y)
  self:onConfirm()
end

return DialogueWindow