
--[[===============================================================================================

MemberInfoWindow
---------------------------------------------------------------------------------------------------
A window that shows HP and MP of a troop member.

=================================================================================================]]

-- Imports
local MemberInfo = require('core/gui/general/widget/MemberInfo')
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')

local MemberInfoWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(member : Battler) The initial member.
-- @param(...) Other default parameters from Window:init.
function MemberInfoWindow:init(member, ...)
  self.member = member
  Window.init(self, ...)
end
-- Overrides Window:createContent.
-- Creates the content of the initial member.
function MemberInfoWindow:createContent(...)
  Window.createContent(self, ...)
  self:setMember(self.member)
end

---------------------------------------------------------------------------------------------------
-- Member
---------------------------------------------------------------------------------------------------

-- @param(member : Battler) Changes the member info to another member's.
function MemberInfoWindow:setMember(member)
  self.member = member
  if self.info then
    self.info:destroy()
    self.content:removeElement(self.info)
  end
  local w = self.width - self:hPadding() * 2
  local h = self.height - self:vPadding() * 2
  self.info = MemberInfo(self.member, w, h, Vector(-w / 2, -h / 2))
  self.info:updatePosition(self.position)
  self.content:add(self.info)
  if not self.open then
    self.info:hide()
  end
end
-- Sets the paging.
-- @param(current : number) Current page.
-- @param(max : number) Total number of pages.
function MemberInfoWindow:setPage(current, max)
  if not self.page then
    local font = Fonts.gui_tiny
    local x = -self.width / 2 + self:hPadding()
    local y = self.height / 2 - self:vPadding() - 6
    self.page = SimpleText('', Vector(x, y, -1), self.width - self:hPadding(), 'left', font)
    self.content:add(self.page)
  end
  local text = ''
  if current then
    text = max and (current .. '/' .. max) or (current .. '')
  end
  self.page:setText(text)
  self.page:redraw()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

function MemberInfoWindow:__tostring()
  return 'Member Info Window'
end

return MemberInfoWindow