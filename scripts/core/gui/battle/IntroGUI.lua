
--[[===============================================================================================

IntroGUI
---------------------------------------------------------------------------------------------------
The GUI that is shown in the beginning of the battle.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local IntroWindow = require('core/gui/battle/window/IntroWindow')
local MemberListWindow = require('core/gui/members/window/MemberListWindow')
local Troop = require('core/battle/Troop')

local IntroGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function IntroGUI:init(...)
  self.name = 'Intro GUI'
  self.troop = Troop()
  GUI.init(self, ...)
end
-- Overrides GUI:createWindows.
function IntroGUI:createWindows()
  self:createMainWindow()
  self:createMembersWindow()
end
-- Creates the first window, with main commands.
function IntroGUI:createMainWindow()
  local window = IntroWindow(self)
  self:setActiveWindow(window)
  self.mainWindow = window
end
-- Creates window with members to manage.
function IntroGUI:createMembersWindow()
  self.membersWindow = MemberListWindow(self.troop, self)
  self.membersWindow:setVisible(false)
end

return IntroGUI