
--[[===============================================================================================

IntroGUI
---------------------------------------------------------------------------------------------------
The GUI that is shown in the beginning of the battle.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local IntroWindow = require('core/gui/battle/window/IntroWindow')
local MemberListWindow = require('core/gui/general/window/MemberListWindow')
local Troop = require('core/battle/Troop')

local IntroGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function IntroGUI:createWindows()
  self.name = 'Intro GUI'
  self:createMainWindow()
  self:createMembersWindow()
end

function IntroGUI:createMainWindow()
  local window = IntroWindow(self, self.troop)
  self:setActiveWindow(window)
  self.mainWindow = window
end

function IntroGUI:createMembersWindow()
  self.troop = Troop(SaveManager:currentTroop())
  self.membersWindow = MemberListWindow(self.troop, self)
  self.membersWindow:setVisible(false)
end

return IntroGUI
