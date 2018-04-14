
--[[===============================================================================================

FieldGUI
---------------------------------------------------------------------------------------------------
The GUI that is openned when player presses the menu button in the field.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local FieldCommandWindow = require('core/gui/field/window/FieldCommandWindow')
local GoldWindow = require('core/gui/general/window/GoldWindow')
local LocalWindow = require('core/gui/general/window/LocalWindow')
local MemberGUI = require('core/gui/members/MemberGUI')
local MemberListWindow = require('core/gui/members/window/MemberListWindow')
local QuitWindow = require('core/gui/field/window/QuitWindow')
local SaveWindow = require('core/gui/general/window/SaveWindow')
local TimeWindow = require('core/gui/general/window/TimeWindow')
local Troop = require('core/battle/Troop')
local Vector = require('core/math/Vector')

local FieldGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides GUI:createWindows.
function FieldGUI:createWindows()
  self.name = 'Main GUI'
  self.troop = Troop()
  self:createMainWindow()
  self:createGoldWindow()
  self:createLocalWindow()
  self:createTimeWindow()
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
-- Creates the window that shows the troop's gold.
function FieldGUI:createGoldWindow()
  local w, h = self.mainWindow.width, 32
  local x = ScreenManager.width / 2 - self:windowMargin() - w / 2
  local y = ScreenManager.height / 2 - self:windowMargin() - h / 2
  self.goldWindow = GoldWindow(self, w, h, Vector(x, y))
  self.goldWindow:setGold(self.troop.gold)
end
-- Creates the window that shows the troop's gold.
function FieldGUI:createLocalWindow()
  local w, h = ScreenManager.width - self.mainWindow.width - self:windowMargin() * 4 - self.goldWindow.width, 32
  local x = self.goldWindow.position.x - w / 2 - self.goldWindow.width / 2 - self:windowMargin()
  local y = self.goldWindow.position.y
  self.localWindow = LocalWindow(self, w, h, Vector(x, y))
  self.localWindow:setLocal(FieldManager.currentField.prefs.name)
end
-- Creates the window that shows the troop's gold.
function FieldGUI:createTimeWindow()
  local w, h = self.goldWindow.width, self.goldWindow.height
  local x = self.mainWindow.position.x
  local y = self.goldWindow.position.y
  self.timeWindow = TimeWindow(self, w, h, Vector(x, y))
  self.timeWindow:setTime(SaveManager:playTime())
end
-- Creates the member list window the shows when player selects "Characters" button.
function FieldGUI:createMembersWindow()
  local w = MemberListWindow(self.troop, self)
  local x = ScreenManager.width / 2 - w.width / 2 - self:windowMargin()
  local y = -ScreenManager.height / 2 + w.height / 2 + self:windowMargin()
  w:setXYZ(x, y)
  w:setSelectedButton(nil)
  self.membersWindow = w
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
  self.membersWindow.highlight:hide()
  self.mainWindow:activate()
end

return FieldGUI