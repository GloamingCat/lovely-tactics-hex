
--[[===============================================================================================

TitleGUI
---------------------------------------------------------------------------------------------------
The GUI that is shown in the end of the battle.

=================================================================================================]]

-- Imports
local TitleCommandWindow = require('core/gui/start/window/TitleCommandWindow')
local GUI = require('core/gui/GUI')
local Text = require('core/graphics/Text')

local TitleGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------------------------------------

-- Implements GUI:createWindows.
function TitleGUI:createWindows()
  self.name = 'Title GUI'
  self:createTopText()
  self:createCommandWindow()
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
  GUI.hide(self, ...)
  self.topText:setVisible(false)
end

return TitleGUI