
--[[===============================================================================================

MemberInfoWindow
---------------------------------------------------------------------------------------------------
A window that shows HP and MP of a troop member.

=================================================================================================]]

local Window = require('core/gui/Window')
local MemberInfoWindow = class(Window)

function MemberInfoWindow:createContent(...)
  Window.createContent(self, ...)
end

function MemberInfoWindow:setMember(member)
  
end

return MemberInfoWindow