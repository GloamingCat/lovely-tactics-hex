
--[[===============================================================================================

MemberGUI
---------------------------------------------------------------------------------------------------
The GUI that is shown when the player chooses a troop member to manage.

=================================================================================================]]

local GUI = require('core/gui/GUI')
local CommandWindow = require('core/gui/members/window/CommandWindow')
local MemberWindow = require('core/gui/members/window/MemberWindow')
local Vector = require('core/math/Vector')

local MemberGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(troop : Troop) current troop (player's troop by default)
-- @param(memberID : number) current selected member on the list (first one by default)
function MemberGUI:init(members, memberID)
  self.name = 'Member GUI'
  self.members = members
  self.memberID = memberID or 1
  GUI.init(self)
end
-- Overrides GUI:createWindows.
function MemberGUI:createWindows()
  self:createCommandWindow()
  self:createMemberWindow()
  self:setActiveWindow(self.commandWindow)
end

function MemberGUI:createCommandWindow()
  local window = CommandWindow(self)
  window:setXYZ((window.width - ScreenManager.width) / 2 + self:windowMargin(), 
      (window.height - ScreenManager.height) / 2 + self:windowMargin())
  self.commandWindow = window
end

function MemberGUI:createMemberWindow()
  local w = ScreenManager.width - self.commandWindow.width - self:windowMargin() * 3
  local h = self.commandWindow.height
  local x = self.commandWindow.width + self:windowMargin() * 2 + w / 2 - ScreenManager.width / 2
  local y = (h - ScreenManager.height) / 2 + self:windowMargin()
  self.memberWindow = MemberWindow(self, w, h, Vector(x, y))
end

---------------------------------------------------------------------------------------------------
-- Member
---------------------------------------------------------------------------------------------------

-- Selected next troop members.
function MemberGUI:nextMember()
  if self.memberID == #self.members then
    self.memberID = 1
  else
    self.memberID = self.memberID + 1
  end
  self:refreshMember()
end
-- Selected previous troop members.
function MemberGUI:prevMember()
  if self.memberID == 1 then
    self.memberID = #self.members
  else
    self.memberID = self.memberID - 1
  end
  self:refreshMember()
end
-- Refreshs current open windows to match the new selected member.
function MemberGUI:refreshMember()
  local member = self:currentMember()
  self.memberWindow:setMember(member)
  if self.subGUI then
    self.subGUI:setMember(member)
  end
end
-- Gets the current selected troop member.
function MemberGUI:currentMember()
  return self.members[self.memberID]
end

return MemberGUI