
--[[===============================================================================================

Music
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Imports
local Sound = require('core/audio/Sound')

-- Alias
local newSource = love.audio.newSource

local Music = class(Sound)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function Music:init(name, volume, pitch)
  name = 'audio/bgm/' .. name
  local introName = name:gsub('%.', '_intro.', 1)
  print(introName)
  if love.filesystem.exists(introName) then
    self.intro = newSource(introName)
  end
  self.loop = newSource(name)
  assert(self.loop, 'Could not load Music ' .. name)
  self.loop:setLooping(true)
  if self.intro then
    self.intro:setLooping(false)
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

return Music