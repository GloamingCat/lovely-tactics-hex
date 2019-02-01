
--[[===============================================================================================

Music
---------------------------------------------------------------------------------------------------
A type of sounds that loops and may have a non-looping intro.

=================================================================================================]]

-- Imports
local Sound = require('core/audio/Sound')

local Music = class(Sound)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(name : string) Name of the file from the "audio/sfx/" folder.
-- @param(volume : number) Initial volume (from 0 to 100).
-- @param(pitch : number) Initial pitch (from 0 to 100).
-- @param(intro : Source) Intro source (optional).
-- @param(loop : Source) Loop source (optional).
function Music:init(name, volume, pitch, intro, loop)
  self.name = name
  name = 'audio/' .. name
  if intro then
    self.intro = intro
  elseif not loop then
    local introName = name:gsub('%.', '_intro.', 1)
    if love.filesystem.exists(introName) then
      self.intro = love.audio.newSource(introName)
      self.intro:setLooping(false)
    end
  end
  if loop then
    self.loop = loop
  else
    self.loop = love.audio.newSource(name)
    assert(self.loop, 'Could not load Music ' .. name)
    self.loop:setLooping(true)
  end
  self:initSource(self.intro or self.loop, volume, pitch)
end

---------------------------------------------------------------------------------------------------
-- Looping
---------------------------------------------------------------------------------------------------

-- Checks looping.
function Music:update()
  if self.source == self.intro and self:isFinished() then
    self.intro:stop()
    self.source = self.loop
    self:updatePitch()
    self:updateVolume()
    self.source:play()
  end
end
-- Override.
function Music:getDuration(unit)
  return (self.intro and self.intro:getDuration(unit) or 0) + self.loop:getDuration(unit)
end

---------------------------------------------------------------------------------------------------
-- Playing
---------------------------------------------------------------------------------------------------

-- Override.
function Music:stop()
  if self.intro then
    self.intro:rewind()
  end
  self.loop:rewind()
  self.source:stop()
  self.source = self.intro or self.loop
end

---------------------------------------------------------------------------------------------------
-- Volume & Pitch
---------------------------------------------------------------------------------------------------

-- Overrides Sound:updateVolume.
function Music:updateVolume()
  self.source:setVolume((self.volume / 100) * (AudioManager.volumeBGM / 100)
    * AudioManager.fading)
end
-- Overrides Sound:updatePitch.
function Music:updatePitch()
  self.source:setPitch((self.pitch / 100) * (AudioManager.pitchBGM / 100))
end

return Music