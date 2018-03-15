
--[[===============================================================================================

FieldGUI
---------------------------------------------------------------------------------------------------
The GUI that is openned when player presses the menu button in the field.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local FieldCommandWindow = require('core/gui/field/window/FieldCommandWindow')
local MemberGUI = require('core/gui/members/MemberGUI')
local MemberListWindow = require('core/gui/members/window/MemberListWindow')
local QuitWindow = require('core/gui/field/window/QuitWindow')
local SaveWindow = require('core/gui/general/window/SaveWindow')
local Troop = require('core/battle/Troop')

local FieldGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides GUI:createWindows.
function FieldGUI:createWindows()
  self.name = 'Main GUI'
  self.troop = Troop()
  self:createMainWindow()
  self:createMembersWindow()
  self:createQuitWindow()
  self:createSaveWindow()
end
-- Creates the list with the main commands.
function FieldGUI:createMainWindow()
  local w = FieldCommandWindow(self)
  local m = self:windowMargin()
  w:setXYZ((w.width - ScreenManager.width) / 2 + m, (w.height - ScreenManager.height) / 2 + m)
  self.mainWindow = w
  self:setActiveWindow(self.mainWindow)
end
-- Creates the member list window the shows when player selects "Characters" button.
function FieldGUI:createMembersWindow()
  self.membersWindow = MemberListWindow(self.troop, self)
  self.membersWindow:setVisible(false)
end
-- Creates the window the shows when player selects "Quit" button.
function FieldGUI:createQuitWindow()
  self.quitWindow = QuitWindow(self)
  self.quitWindow:setVisible(false)
end
-- Creates the window with the save slots.
function FieldGUI:createSaveWindow()
  self.saveWindow = SaveWindow(self)
  self.saveWindow:setVisible(false)
end

---------------------------------------------------------------------------------------------------
-- Member Input
---------------------------------------------------------------------------------------------------

-- When player selects a character from the member list window.
-- @param(index : number) the index of the button
function FieldGUI:onMemberConfirm(index)
  self:hide()
  local gui = MemberGUI(self.troop, self.membersWindow.list, index)
  GUIManager:showGUIForResult(gui)
  self:show()
end
-- When player cancels from the member list window.
function FieldGUI:onMemberCancel()
  self.membersWindow:hide()
  self.mainWindow:show()
  self.mainWindow:activate()
end

return FieldGUI