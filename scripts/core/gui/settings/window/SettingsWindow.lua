
--[[===============================================================================================

SettingsWindow
---------------------------------------------------------------------------------------------------
Window to change basic system settings.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')
local SpinnerButton = require('core/gui/widget/SpinnerButton')
local SwitchButton = require('core/gui/widget/SwitchButton')

local SettingsWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Implements GridWindow:createWidgets.
function SettingsWindow:createWidgets()
  local config = SaveManager.current.config
  SpinnerButton:fromKey(self, 'volumeBGM', 0, 100, config.volumeBGM).
    bigIncrement = 10
  SpinnerButton:fromKey(self, 'volumeSFX', 0, 100, config.volumeSFX).
    bigIncrement = 10
  
  SpinnerButton:fromKey(self, 'windowScroll', 10, 100, config.windowScroll).
    bigIncrement = 10
  SpinnerButton:fromKey(self, 'fieldScroll', 10, 100, config.fieldScroll).
    bigIncrement = 10
    
  SwitchButton:fromKey(self, 'autoDash', config.autoDash)
  SwitchButton:fromKey(self, 'useMouse', config.useMouse)
  
  Button:fromKey(self, 'resolution').text:setAlign('center')
  Button:fromKey(self, 'keys').text:setAlign('center')
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
-- Change window scroll speed.
function SettingsWindow:windowScrollChange(spinner)
  SaveManager.current.config.windowScroll = spinner.value
end
-- Change field scroll speed.
function SettingsWindow:fieldScrollChange(spinner)
  SaveManager.current.config.fieldScroll = spinner.value
end

---------------------------------------------------------------------------------------------------
-- Switches
---------------------------------------------------------------------------------------------------

-- Change auto dash option.
function SettingsWindow:autoDashChange(button)
  SaveManager.current.config.autoDash = button.value
end
-- Change mouse enabled option.
function SettingsWindow:useMouseChange(button)
  SaveManager.current.config.useMouse = button.value
  InputManager.mouseEnabled = button.value
  if not button.value then
    InputManager.mouse:hide()
    for i = 1, 3 do
      InputManager.keys['mouse' .. i]:onRelease()
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------------------------------

function SettingsWindow:resolutionConfirm()
  self:hide()
  self.GUI:showWindowForResult(self.GUI.resolutionWindow)
  self:show()
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
  return 8
end
-- Overrides GridWindow:cellWidth.
function SettingsWindow:cellWidth()
  return 200
end
-- @ret(string) String representation (for debugging).
function SettingsWindow:__tostring()
  return 'Settings Window'
end

return SettingsWindow