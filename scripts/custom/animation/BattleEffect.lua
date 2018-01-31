
--[[===============================================================================================

BattleEffect
---------------------------------------------------------------------------------------------------

=================================================================================================]]

-- Imports
local Animation = require('core/graphics/Animation')

local BattleEffect = class(Animation)

function BattleEffect:init(...)
  Animation.init(self, ...)
  if self.duration then
    self:setTiming(self.duration / self.rowCount)
  end
end

-- Sets to next frame.
function BattleEffect:nextFrame()
  local lastCol, lastRow = 0, 0
  if self.speed > 0 then
    lastCol, lastRow = self.colCount - 1, self.rowCount - 1
  end
  if self.col ~= lastCol then
    self:nextCol()
  elseif self.row ~= lastRow then
    self:nextCol()
    self:nextRow()
  else
    self:onEnd()
  end
end
-- What happens when the animations finishes.
function BattleEffect:onEnd()
  if self.loop == 0 then
    self.paused = true
  elseif self.loop == 1 then
    self:nextCol()
    self:nextRow()
  elseif self.loop == 2 then
    self.speed = -self.speed
    if self.colCount > 1 then
      self:nextCol()
    else
      self:nextRow()
    end
  end
end

return BattleEffect