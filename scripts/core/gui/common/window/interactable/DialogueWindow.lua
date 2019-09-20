
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
local DescriptionWindow = require('core/gui/common/window/DescriptionWindow')
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')

-- Alias
local deltaTime = love.timer.getDelta
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
  self:initProperties()
  w = w or ScreenManager.width - GUI:windowMargin()
  h = h or ScreenManager.height / 4
  x = x or (w - ScreenManager.width) / 2 + GUI:windowMargin()
  y = y or (ScreenManager.height - h) / 2 - GUI:windowMargin()
  Window.init(self, GUI, w, h, Vector(x, y))
end
-- Sets window's properties.
function DialogueWindow:initProperties()
  self.textSpeed = 40
  self.textSound = Sounds.text
  self.soundFrequence = 4
  self.align = 'left'
  self.nameWidth = 80
  self.nameHeight = 24
end
-- Overrides Window:createContent.
-- Creates a simple text for dialogue.
function DialogueWindow:createContent(width, height)
  Window.createContent(self, width, height)
  local pos = Vector(-width / 2 + self:paddingX(), -height / 2 + self:paddingY())
  self.dialogue = SimpleText('', pos, width - self:paddingX() * 2, self.align, Fonts.gui_dialogue)
  self.dialogue.sprite.wrap = true
  self.content:add(self.dialogue)
  self.nameWindow = DescriptionWindow(self.GUI, self.nameWidth, self.nameHeight)
  self.nameWindow:setVisible(false)
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Called when player presses a mouse button.
function DialogueWindow:onClick(button, x, y)
  self:onConfirm()
end
-- Overrides Window:hide.
function DialogueWindow:hide(...)
  self.nameWindow:setVisible(false)
  Window.hide(self, ...)
end
-- Overrides Window:destroy.
function DialogueWindow:destroy(...)
  self.nameWindow:destroy()
  self.nameWindow:removeSelf()
  Window.destroy(self, ...)
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
-- @param(speaker : table) The speaker's name and position of name box (optional).
function DialogueWindow:showDialogue(text, align, speaker)
  if speaker then
    local x = speaker.x and speaker.x * self.width / 2
    local y = speaker.y and speaker.y * self.height / 2
    self:setName(speaker.name, x, y)
  end
  self.dialogue:setAlign(align)
  self.dialogue:show()
  self:rollText(text)
  self.GUI:waitForResult()
  self.result = nil
  yield()
end
-- Shows text character by character.
-- @param(text : string) The message.
function DialogueWindow:rollText(text)
  self.dialogue.sprite:setText(text)
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
    while not pcall(self.dialogue.sprite.redrawBuffers, self.dialogue.sprite) do
      time = time + 1
      self.dialogue.sprite.cutPoint = math.ceil(time)
    end
    self.dialogue.sprite:redrawBuffers()
    yield()
  end
  self.dialogue.sprite.cutPoint = nil
  self.dialogue.sprite:redrawBuffers()
end

---------------------------------------------------------------------------------------------------
-- Speaker
---------------------------------------------------------------------------------------------------

-- Shows the name of the speaker.
-- @param(text : string) Nil or empty to hide window, any other string to show.
function DialogueWindow:setName(text, x, y)
  if text and text ~= '' then
    self.nameWindow:updateText(text)
    self.nameWindow:packText()
    local nameX = x and (self.position.x + x) or self.nameWindow.position.x
    local nameY = y and (self.position.y + y) or self.nameWindow.position.y
    self.nameWindow:setVisible(true)
    self.nameWindow:setXYZ(nameX, nameY, -5)
  else
    self.nameWindow:setVisible(false)
  end
end

return DialogueWindow
