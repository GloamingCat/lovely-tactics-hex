
--[[===============================================================================================

MemberGUI
---------------------------------------------------------------------------------------------------
The GUI that is shown when the player chooses a troop member to manage.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local MemberCommandWindow = require('core/gui/members/window/MemberCommandWindow')
local MemberInfoWindow = require('core/gui/members/window/MemberInfoWindow')
local Vector = require('core/math/Vector')

local MemberGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(troop : TroopBase) current troop (player's troop by default)
-- @param(memberID : number) current selected member on the list (first one by default)
function MemberGUI:init(troop, battlerList, memberID)
  self.name = 'Member GUI'
  self.troop = troop
  self.members = battlerList
  self.memberID = memberID or 1
  GUI.init(self)
end
-- Overrides GUI:createWindows.
function MemberGUI:createWindows()
  self:createCommandWindow()
  self:createInfoWindow()
  self:setActiveWindow(self.commandWindow)
end
-- Creates the window with the commands for the chosen member.
function MemberGUI:createCommandWindow()
  local window = MemberCommandWindow(self)
  window:setXYZ((window.width - ScreenManager.width) / 2 + self:windowMargin(), 
      (window.height - ScreenManager.height) / 2 + self:windowMargin())
  self.commandWindow = window
end
-- Creates the window with the information of the chosen member.
function MemberGUI:createInfoWindow()
  local w = ScreenManager.width - self.commandWindow.width - self:windowMargin() * 3
  local h = self.commandWindow.height
  local x = self.commandWindow.width + self:windowMargin() * 2 + w / 2 - ScreenManager.width / 2
  local y = (h - ScreenManager.height) / 2 + self:windowMargin()
  local member = self:currentMember()
  self.infoWindow = MemberInfoWindow(member, self, w, h, Vector(x, y))
end

---------------------------------------------------------------------------------------------------
-- Member
---------------------------------------------------------------------------------------------------

-- Selected next troop members.
function MemberGUI:nextMember()
  repeat
    if self.memberID == #self.members then
      self.memberID = 1
    else
      self.memberID = self.memberID + 1
    end
  until not self.subGUI or self.subGUI:memberEnabled(self:currentMember())
  self:refreshMember()
end
-- Selected previous troop members.
function MemberGUI:prevMember()
  repeat
    if self.memberID == 1 then
      self.memberID = #self.members
    else
      self.memberID = self.memberID - 1
    end
  until not self.subGUI or self.subGUI:memberEnabled(self:currentMember())
  self:refreshMember()
end
-- Refreshs current open windows to match the new selected member.
function MemberGUI:refreshMember()
  local member = self:currentMember()
  self.commandWindow:setMember(member)
  self.infoWindow:setMember(member)
  if self.subGUI then
    self.subGUI:setMember(member)
  end
end
-- Gets the current selected troop member.
function MemberGUI:currentMember()
  return self.members[self.memberID]
end
-- Overrides GUI:hide.
-- Saves troop modifications.
function MemberGUI:hide(...)
  self.troop:storeSave()
  GUI.hide(self, ...)
end
-- Overrides GUI:show.
-- Refreshes member info.
function MemberGUI:show(...)
  self:refreshMember()
  GUI.show(self, ...)
end

---------------------------------------------------------------------------------------------------
-- Sub GUI
---------------------------------------------------------------------------------------------------

-- Shows a sub GUI under the command window.
-- @param(GUI : class) The class of the GUI to be open.
function MemberGUI:showSubGUI(GUI)
  local gui = GUI(self)
  self.subGUI = gui
  gui:setMember(self:currentMember(), self.battler)
  self:setActiveWindow(nil)
  GUIManager:showGUIForResult(gui)
  self:setActiveWindow(self.commandWindow)
  self.subGUI = nil
end
-- The total height occupied by the command and info windows.
-- @ret(number) Height of the GUI including window margin.
function MemberGUI:getHeight()
  return self.commandWindow.height + self:windowMargin() * 2
end

return MemberGUI