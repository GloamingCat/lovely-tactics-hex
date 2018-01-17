
--[[===============================================================================================

MainGUI
---------------------------------------------------------------------------------------------------
The GUI that is openned when player presses the menu button in the field.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local MainWindow = require('core/gui/field/window/MainWindow')
local MemberListWindow = require('core/gui/general/window/MemberListWindow')
local Troop = require('core/battle/Troop')

local MainGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function MainGUI:createWindows()
  self.name = 'Main GUI'
  self:createMainWindow()
  self:createMembersWindow()
end

function MainGUI:createMainWindow()
  self.mainWindow = MainWindow(self)
  self:setActiveWindow(self.mainWindow)
end

function MainGUI:createMembersWindow()
  self.troop = Troop(SaveManager:currentTroop())
  self.membersWindow = MemberListWindow(self.troop, self)
  self.membersWindow:setVisible(false)
end

return MainGUI