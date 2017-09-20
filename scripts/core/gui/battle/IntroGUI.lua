
--[[===============================================================================================

IntroGUI
---------------------------------------------------------------------------------------------------
The GUI that is shown in the beginning of the battle.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local IntroWindow = require('core/gui/battle/window/IntroWindow')
local TargetWindow = require('core/gui/battle/window/TargetWindow')
local Vector = require('core/math/Vector')

local IntroGUI = class(GUI)

function IntroGUI:createWindows()
  self.name = 'Intro GUI'
  self:createIntroWindow()
end

function IntroGUI:createIntroWindow()
  local introWindow = IntroWindow(self, self.troop)
  self.windowList:add(introWindow)
  self:setActiveWindow(introWindow)
  introWindow:setPosition(Vector(-ScreenManager.width / 2 + introWindow.width / 2 + 8, 
      -ScreenManager.height / 2 + introWindow.height / 2 + 8))
  return introWindow
end

return IntroGUI
