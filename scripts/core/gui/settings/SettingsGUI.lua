
--[[===============================================================================================

SettingsGUI
---------------------------------------------------------------------------------------------------
Screen to change system settings.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local ResolutionWindow = require('core/gui/settings/window/ResolutionWindow')
local SettingsWindow = require('core/gui/settings/window/SettingsWindow')

local SettingsGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Override GUI:createWindows.
function SettingsGUI:createWindows()
  self.name = 'Settings GUI'
  self:createMainWindow()
  self:createResolutionWindow()
  self:setActiveWindow(self.mainWindow)
end
-- Creates the window with the main config options.
function SettingsGUI:createMainWindow()
  self.mainWindow = SettingsWindow(self)
end
-- Creates the window with the resolution options.
function SettingsGUI:createResolutionWindow()
  self.resolutionWindow = ResolutionWindow(self)
  self.resolutionWindow:setVisible(false)
end

return SettingsGUI