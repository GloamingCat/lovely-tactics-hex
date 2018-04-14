
--[[===============================================================================================

TitleGUI
---------------------------------------------------------------------------------------------------
The GUI that is shown in the end of the battle.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local LoadWindow = require('core/gui/save/window/LoadWindow')
local Text = require('core/graphics/Text')
local TitleCommandWindow = require('core/gui/start/window/TitleCommandWindow')

local TitleGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------------------------------------

-- Implements GUI:createWindows.
function TitleGUI:createWindows()
  self.name = 'Title GUI'
  self:createTopText()
  self:createCommandWindow()
  self:createLoadWindow()
  self:setActiveWindow(self.commandWindow)
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
  self.topText:setVisible(true)
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
-- General
---------------------------------------------------------------------------------------------------

-- Overrides GUI:destroy to destroy top text.
function TitleGUI:destroy(...)
  GUI.destroy(self, ...)
  self.topText:destroy()
end
-- Overrides GUI:show to show top text before openning windows.
function TitleGUI:show(...)
  self.topText:setVisible(true)
  GUI.show(self, ...)
end
-- Overrides GUI:hide to hide top text after closing windows.
function TitleGUI:hide(...)
  self.topText:setVisible(false)
  GUI.hide(self, ...)
end

return TitleGUI