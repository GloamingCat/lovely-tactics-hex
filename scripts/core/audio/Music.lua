
--[[===============================================================================================

Music
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Imports
local Sound = require('core/audio/Sound')

local Music = class(Sound)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function Music:init(name, volume, pitch, intro, loop)
  print(intro, loop)
  self.name = name
  name = 'audio/bgm/' .. name
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
  if self.source == self.intro and self:finished() then
    self.intro:stop()
    self.source = self.loop
    self:updatePitch()
    self:updateVolume()
    self.source:play()
  end
end
-- Override.
function Music:duration(unit)
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

function Music:updateVolume()
  self.source:setVolume((self.volume / 100) * (AudioManager.volumeBGM / 100)
    * AudioManager.fading)
end

function Music:updatePitch()
  self.source:setPitch((self.pitch / 100) * (AudioManager.pitchBGM / 100))
end

return Music