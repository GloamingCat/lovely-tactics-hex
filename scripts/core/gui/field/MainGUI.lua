
--[[===============================================================================================

MainGUI
---------------------------------------------------------------------------------------------------
The GUI that is openned when player presses the menu button in the field.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local MainWindow = require('core/gui/field/window/MainWindow')
local MemberListWindow = require('core/gui/members/window/MemberListWindow')
local TroopBase = require('core/battle/TroopBase')

local MainGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function MainGUI:createWindows()
  self.name = 'Main GUI'
  self.troop = TroopBase()
  self:createMainWindow()
  self:createMembersWindow()
end

function MainGUI:createMainWindow()
  local w = MainWindow(self)
  local m = self:windowMargin()
  w:setXYZ((w.width - ScreenManager.width) / 2 + m, (w.height - ScreenManager.height) / 2 + m)
  self.mainWindow = w
  self:setActiveWindow(self.mainWindow)
end

function MainGUI:createMembersWindow()
  self.membersWindow = MemberListWindow(self.troop, self)
  self.membersWindow:setVisible(false)
end

return MainGUI