
--[[===============================================================================================

BattleEffect
---------------------------------------------------------------------------------------------------

=================================================================================================]]

-- Imports
local Animation = require('core/graphics/Animation')

local BattleEffect = class(Animation)

function BattleEffect:init(...)
  Animation.init(self, ...)
  self.duration = self.duration * self.rowCount
end

-- Sets to next frame.
function BattleEffect:nextFrame()
  local lastIndex = self.rowCount * self.colCount + 1
  if self.index < lastIndex then
    self:nextCol()
  else
    self:onEnd()
  end
end
-- Plays the audio in the current index, if any.
function BattleEffect:playAudio()
  local index = self.row * self.colCount + self.col + 1
  if self.audio and self.audio[index] then
    AudioManager:playSFX(self.audio[index])
  end
end
-- What happens when the animations finishes.
function BattleEffect:onEnd()
  if self.loop then
    self:nextCol()
    self:nextRow()
  elseif self.loopDuration then
    self.loop = true
    self:setFrames(self.loopDuration, self.loopPattern)
    self.index = 0
    self:nextCol()
    self:nextRow()
  else
    self.paused = true
  end
end

return BattleEffect