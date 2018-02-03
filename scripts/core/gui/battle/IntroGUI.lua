
--[[===============================================================================================

IntroGUI
---------------------------------------------------------------------------------------------------
The GUI that is shown in the beginning of the battle.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local IntroWindow = require('core/gui/battle/window/IntroWindow')
local MemberGUI = require('core/gui/members/MemberGUI')
local MemberListWindow = require('core/gui/members/window/MemberListWindow')
local Troop = require('core/battle/Troop')

local IntroGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function IntroGUI:init(...)
  self.name = 'Intro GUI'
  self.troop = TroopManager.troops[TroopManager.playerParty]
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

---------------------------------------------------------------------------------------------------
-- Member Input
---------------------------------------------------------------------------------------------------

-- When player selects a character from the member list window.
-- @param(index : number) the index of the button
function IntroGUI:onMemberConfirm(index)
  self:hide()
  local gui = MemberGUI(self.troop, self.membersWindow.list, index)
  GUIManager:showGUIForResult(gui)
  self:show()
end
-- When player cancels from the member list window.
function IntroGUI:onMemberCancel()
  self.membersWindow:hide()
  self.mainWindow:show()
  self.mainWindow:activate()
end

return IntroGUI