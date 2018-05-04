
--[[===============================================================================================

SettingsWindow
---------------------------------------------------------------------------------------------------

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')
local SpinnerButton = require('core/gui/widget/SpinnerButton')

local SettingsWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function SettingsWindow:createWidgets()
  SpinnerButton:fromKey(self, 'volumeBGM', 0, 100, 100)
  SpinnerButton:fromKey(self, 'volumeSFX', 0, 100, 100)
  
  SpinnerButton:fromKey(self, 'windowScroll', 0, 100, 50)
  SpinnerButton:fromKey(self, 'fieldScroll', 0, 100, 50)
  
  Button:fromKey(self, 'resolution')
  Button:fromKey(self, 'keys')
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

function SettingsWindow:colCount()
  return 1
end

function SettingsWindow:rowCount()
  return 6
end

function SettingsWindow:cellWidth()
  return 240
end

function SettingsWindow:__tostring()
  return 'Settings Window'
end

return SettingsWindow