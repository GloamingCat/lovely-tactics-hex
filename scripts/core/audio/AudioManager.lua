
--[[===============================================================================================

AudioManager
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Imports
local Music = require('core/audio/Music')
local Sound = require('core/audio/Sound')
local List = require('core/datastruct/List')

-- Alias
local deltaTime = love.timer.getDelta
local yield = coroutine.yield
local min = math.min

local AudioManager = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function AudioManager:init()
  -- BGM
  self.BGM = nil
  self.nextBGM = nil
  self.fading = 1
  self.fadingSpeed = 0
  self.volumeBGM = 1
  self.pitchBGM = 1
end

function AudioManager:update()
  self:updateBGM()
end

---------------------------------------------------------------------------------------------------
-- Volume
---------------------------------------------------------------------------------------------------

function AudioManager:getBGMVolume()
  return self.volumeBGM
end

function AudioManager:setBGMVolume(v)
  self.volumeBGM = v
  self:updateVolume()
end

function AudioManager:updateBGMVolume()
  if self.BGM then
    self.BGM:setVolume((1 - self.fading) * self.volumeBGM)
  end
  if self.nextBGM then
    self.nextBGM:setVolume(self.fading * self.volumeBGM)
  end
end

---------------------------------------------------------------------------------------------------
-- Pitch
---------------------------------------------------------------------------------------------------

function AudioManager:getBGMPitch()
  return self.pitchBGM
end

function AudioManager:setBGMPitch(p)
  self.pitchBGM = p
  if self.BGM then 
    self.BGM:setPitch(p)
  end
  if self.nextBGM then 
    self.nextBGM:setPitch(p) 
  end
end

---------------------------------------------------------------------------------------------------
-- BGM - General
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Stops current playing BGM (if any) and starts a new one.
-- @param(name : string) the name of the new BGM
-- @param(time : number) the duration of the fading transition
function AudioManager:playBGM(name, volume, pitch, time, wait)
  if self.nextBGM then
    self.nextBGM:stop()
  end
  if self.BGM then
    self.BGM:play()
  end
  self.nextBGM = Music(name, volume, pitch)
  self.nextBGM:play()
  self.nextBGM:setVolume(0)
  self:fade(time, wait)
end

function AudioManager:resumeBGM(time, wait)
  self.BGM, self.nextBGM = self.nextBGM, self.BGM
  if self.BGM then
    self.BGM:resume()
  end
  if self.nextBGM then
    self.nextBGM:resume()
  end
  self:fade(time, wait)
end

function AudioManager:pauseBGM(time, wait)
  self:fade(time, wait)
end

---------------------------------------------------------------------------------------------------
-- BGM - Update
---------------------------------------------------------------------------------------------------

-- Updates fading and BGMs.
function AudioManager:updateBGM()
  if self.fading < 1 then
    self.fading = min(1, self.fading + deltaTime() * self.fadingSpeed)
    self:updateBGMVolume()
    if self.fading >= 1 then
      self:playNextBGM()
    end
  end
  if self.BGM then
    self.BGM:update()
  end
  if self.nextBGM then
    self.nextBGM:update()
  end
end
-- Replaces current BGM with the next BGM.
function AudioManager:playNextBGM()
  if self.BGM then
    self.BGM:stop()
  end
  if self.nextBGM then
    self.BGM = self.nextBGM
    self.nextBGM = nil
  end
end

---------------------------------------------------------------------------------------------------
-- Fading
---------------------------------------------------------------------------------------------------

-- @param(time : number) the duration of the fading
-- @param(wait : boolean) true to only return when the fading finishes
function AudioManager:fade(time, wait)
  if time > 0 then
    self.fadingSpeed = 1 / time * 60
    self.fading = 0
    if wait then
      self:waitForBGMFading()
    end
  else
    self.nextBGM:setVolume(1)
    self:playNextBGM()
  end
end
-- [COROUTINE] Waits until the fading value is 1.
function AudioManager:waitForBGMFading()
  local fiber = _G.Fiber
  if self.fadingFiber then
    self.fadingFiber:interrupt()
  end
  self.fadingFiber = fiber
  while self.fading < 1 do
    yield()
  end
  if fiber:running() then
    self.fadingFiber = nil
  end
end

return AudioManager