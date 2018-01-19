
--[[===============================================================================================

BonusStatus
---------------------------------------------------------------------------------------------------
A simple status that adds bonus in attributes and element defense.

=================================================================================================]]

-- Imports
local Status = require('core/battle/Status')

local BonusStatus = class(Status)

function BonusStatus:init(...)
  Status.init(self, ...)
  if self.equip and self.equip.equip then
    self:addBonus(self.equip.equip)
  end
end

return BonusStatus