
--[[===============================================================================================

Sound
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Alias
local newSource = love.audio.newSource

local Sound = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function Sound:init(name, volume, pitch)
  local source = newSource('audio/sfx/' .. name)
  assert(source, 'Could not load Sound ' .. name)
  self:initSource(source, volume, pitch)
end

function Sound:initSource(source, volume, pitch)
  self.volume = volume or 1
  self.pitch = pitch or 1
  self.source = source
  self.source:setVolume(self.volume)
  self.source:setPitch(self.pitch)
  self.paused = true
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Tells if the sound already ended.
-- @ret(boolean)
function Sound:finished()
  return not (self.source:isPlaying() or self.paused)
end
-- @param(unit : string) "seconds" or "samples" (first by default)
-- @ret(number) the duration in the given unit
function Sound:duration()
  return self.source:getDuration()
end

---------------------------------------------------------------------------------------------------
-- Playing
---------------------------------------------------------------------------------------------------

function Sound:play()
  self.paused = false
  self.source:play()
end

function Sound:stop()
  self.paused = true
  self.source:stop()
end

function Sound:resume()
  self.paused = false
  self.source:resume()
end

function Sound:pause()
  self.paused = true
  self.source:pause()
end

function Sound:setPaused(paused)
  if paused or self.paused then
    self.source:pause()
  else
    self.source:resume()
  end
end

---------------------------------------------------------------------------------------------------
-- Volume & Pitch
---------------------------------------------------------------------------------------------------

-- @ret(number) local BGM volume
function Sound:getVolume()
  return self.volume
end
-- @param(m : number) AudioManager's BGM volume
-- @param(l : number) new local BGM volume
function Sound:setVolume(m, l)
  self.volume = l or self.volume
  self.source:setVolume(self.volume * m)
end
-- @ret(number) local BGM pitch
function Sound:getPitch()
  return self.pitch
end
-- @param(m : number) AudioManager's BGM pitch
-- @param(l : number) new local BGM pitch
function Sound:setPitch(m, l)
  self.pitch = m or self.pitch
  self.source:setPitch(self.pitch * m)
end

return Sound