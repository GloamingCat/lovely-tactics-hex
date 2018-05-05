
--[[===============================================================================================

SettingsWindow
---------------------------------------------------------------------------------------------------
Window to change basic system settings.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')
local SpinnerButton = require('core/gui/widget/SpinnerButton')

local SettingsWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Implements GridWindow:createWidgets.
function SettingsWindow:createWidgets()
  SpinnerButton:fromKey(self, 'volumeBGM', 0, 100, SaveManager.current.config.volumeBGM).
    bigIncrement = 10
  SpinnerButton:fromKey(self, 'volumeSFX', 0, 100, SaveManager.current.config.volumeSFX).
    bigIncrement = 10
  
  SpinnerButton:fromKey(self, 'windowScroll', 0, 100, 50)
  SpinnerButton:fromKey(self, 'fieldScroll', 0, 100, 50)
  
  Button:fromKey(self, 'resolution')
  Button:fromKey(self, 'keys')
end

---------------------------------------------------------------------------------------------------
-- Spinners
---------------------------------------------------------------------------------------------------

-- Change the BGM volume.
function SettingsWindow:volumeBGMChange(spinner)
  SaveManager.current.config.volumeBGM = spinner.value
  AudioManager:setBGMVolume(spinner.value / 100)
end
-- Change the SFX volume.
function SettingsWindow:volumeSFXChange(spinner)
  SaveManager.current.config.volumeSFX = spinner.value
  AudioManager:setSFXVolume(spinner.value / 100)
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function SettingsWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function SettingsWindow:rowCount()
  return 6
end
-- Overrides GridWindow:cellWidth.
function SettingsWindow:cellWidth()
  return 240
end
-- @ret(string) String representation (for debugging).
function SettingsWindow:__tostring()
  return 'Settings Window'
end

return SettingsWindow