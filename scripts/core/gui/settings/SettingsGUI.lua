
--[[===============================================================================================

SettingsGUI
---------------------------------------------------------------------------------------------------
Screen to change system settings.

=================================================================================================]]

-- Imports
local SettingsWindow = require('core/gui/settings/window/SettingsWindow')
local GUI = require('core/gui/GUI')

local SettingsGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Override GUI:createWindows.
function SettingsGUI:createWindows()
  local mainWindow = SettingsWindow(self)
  self:setActiveWindow(mainWindow)
end

return SettingsGUI