
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
  self.volume = volume or 100
  self.pitch = pitch or 100
  self.source = source
  self:updateVolume()
  self:updatePitch()
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

-- @param(v : number) New local volume.
function Sound:setVolume(v)
  self.volume = v or self.volume
  self:updateVolume()
end
-- @param(p : number) New local pitch.
function Sound:setPitch(p)
  self.pitch = p or self.pitch
  self:updatePitch()
end

function Sound:updateVolume()
  self.source:setVolume((self.volume / 100) * (AudioManager.volumeSFX / 100))
  print ((self.volume / 100) * (AudioManager.volumeSFX / 100))
end

function Sound:updatePitch()
  self.source:setPitch((self.pitch / 100) * (AudioManager.pitchSFX / 100))
end

return Sound