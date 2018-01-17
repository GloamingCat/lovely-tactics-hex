
--[[===============================================================================================

MemberWindow
---------------------------------------------------------------------------------------------------
A window that shows HP and MP of a troop member.

=================================================================================================]]

local Window = require('core/gui/Window')
local MemberWindow = class(Window)

function MemberWindow:createContent(...)
  Window.createContent(self, ...)
end

function MemberWindow:setMember(member)
  
end

return MemberWindow