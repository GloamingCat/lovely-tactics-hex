
--[[===============================================================================================

TitleGUI
---------------------------------------------------------------------------------------------------
The GUI that is shown in the end of the battle.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local LoadWindow = require('core/gui/save/window/LoadWindow')
local Sprite = require('core/graphics/Sprite')
local Text = require('core/graphics/Text')
local TitleCommandWindow = require('core/gui/start/window/TitleCommandWindow')

local TitleGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------------------------------------

-- Implements GUI:createWindows.
function TitleGUI:createWindows()
  self.name = 'Title GUI'
  self.coverSpeed = 2
  self:createCover()
  self:createTopText()
  self:createCommandWindow()
  self:createLoadWindow()
  self:setActiveWindow(self.commandWindow)
  self:showCover()
end
-- Creates cover sprite.
function TitleGUI:createCover()
  local id = Config.screen.coverID
  if id then
    self.cover = ResourceManager:loadSprite(Database.animations[id], GUIManager.renderer)
    self.cover:setXYZ(0, 0, 10)
    self.cover.texture:setFilter('linear', 'linear')
    self.cover:setRGBA(nil, nil, nil, 0)
  end
end
-- Creates the text at the top of the screen to show that the player won.
function TitleGUI:createTopText()
  local prop = {
    ScreenManager.width,
    'center',
    Fonts.gui_title }
  self.topText = Text(Config.name, prop, GUIManager.renderer)
  local x = -ScreenManager.width / 2
  local y = -ScreenManager.height / 2 + self:windowMargin() * 2
  self.topText:setXYZ(x, y)
  self.topText:setRGBA(nil, nil, nil, 0)
end
-- Creates the main window with New / Load / etc.
function TitleGUI:createCommandWindow()
  local window = TitleCommandWindow(self)
  window:setXYZ((window.width - ScreenManager.width) / 2 + self:windowMargin(),
    (ScreenManager.height - window.height) / 2 - self:windowMargin())
  self.commandWindow = window
end
-- Creates the window with the save files to load.
function TitleGUI:createLoadWindow()
  if next(SaveManager.saves) ~= nil then
    local window = LoadWindow(self)
    window:setVisible(false)
    self.loadWindow = window
  end
end

---------------------------------------------------------------------------------------------------
-- Cover
---------------------------------------------------------------------------------------------------

-- Fades in cover and title.
function TitleGUI:showCover()
  local time = 0
  while time < 1 do
    time = math.min(1, time + love.timer.getDelta() * self.coverSpeed)
    self.topText:setRGBA(nil, nil, nil, time * 255)
    if self.cover then
      self.cover:setRGBA(nil, nil, nil, time * 255)
    end
    coroutine.yield()
  end
end
-- Faces out cover and title.
function TitleGUI:hideCover()
  local time = 1
  while time > 0 do
    time = math.max(0, time - love.timer.getDelta() * self.coverSpeed)
    self.topText:setRGBA(nil, nil, nil, time * 255)
    if self.cover then
      self.cover:setRGBA(nil, nil, nil, time * 255)
    end
    coroutine.yield()
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Overrides GUI:destroy to destroy top text.
function TitleGUI:destroy(...)
  GUI.destroy(self, ...)
  self.topText:destroy()
  if self.cover then
    self.cover:destroy()
  end
end
-- Overrides GUI:windowMargin.
function TitleGUI:windowMargin()
  return 10
end

return TitleGUI