
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

-- Initializes with no sound.
function AudioManager:init()
  -- BGM
  self.BGM = nil
  self.nextBGM = nil
  self.fading = 1
  self.fadingSpeed = 0
  self.volumeBGM = 1
  self.pitchBGM = 1
  self.pausedBGM = false
  -- SFX
  self.sfx = List()
  self.volumeSFX = 1
  self.pitchSFX = 1
  self.paused = false
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Updates BGM and SFX audio.
function AudioManager:update()
  self:updateBGM()
  self:updateSFX()
end

function AudioManager:setPaused(paused)
  self.paused = paused
  if self.BGM then
    self.BGM:setPaused(paused)
  end
  if self.nextBGM then
    self.nextBGM:setPaused(paused)
  end
  for i = 1, #self.sfx do
    self.sfx[i]:setPaused(paused)
  end
end

---------------------------------------------------------------------------------------------------
-- Volume
---------------------------------------------------------------------------------------------------

-- @ret(number) volume multiplier for current BGM
function AudioManager:getBGMVolume()
  return self.volumeBGM
end
-- @param(v : number) volume multiplier for current BGM
function AudioManager:setBGMVolume(v)
  self.volumeBGM = v
  self:updateVolume()
end
-- Updates the volume of all BGM according to volume multiplier.
function AudioManager:updateBGMVolume()
  if self.BGM then
    self.BGM:setVolume((1 - self.fading) * self.volumeBGM)
  end
  if self.nextBGM then
    self.nextBGM:setVolume(self.fading * self.volumeBGM)
  end
end
-- @ret(number) volume multiplier for current SFX
function AudioManager:getSFXVolume()
  return self.volumeSFX
end
-- @param(v : number) volume multiplier for current SFX
function AudioManager:setSFXVolume(v)
  self.volumeSFX = v
  for i = 1, #self.sfx do
    self.sfx[i]:setVolume(v)
  end
end

---------------------------------------------------------------------------------------------------
-- Pitch
---------------------------------------------------------------------------------------------------

-- @ret(number) pitch multiplier for current BGM
function AudioManager:getBGMPitch()
  return self.pitchBGM
end
-- @param(p : number) pitch multiplier for current BGM
function AudioManager:setBGMPitch(p)
  self.pitchBGM = p
  if self.BGM then 
    self.BGM:setPitch(p)
  end
  if self.nextBGM then 
    self.nextBGM:setPitch(p) 
  end
end
-- @ret(number) pitch multiplier for current SFX
function AudioManager:getSFXPitch()
  return self.pitchSFX
end
-- @param(p : number) pitch multiplier for current SFX
function AudioManager:setSFXPitch(p)
  self.pitchSFX = p
  for i = 1, #self.sfx do
    self.sfx[i]:setPitch(p)
  end
end

---------------------------------------------------------------------------------------------------
-- SFX
---------------------------------------------------------------------------------------------------

-- @param(sfx : table) table with file's name (from audio/sfx folder), volume and pitch
function AudioManager:playSFX(sfx)
  local sound = Sound(sfx.name, sfx.volume / 100, sfx.pitch / 100)
  self.sfx:add(sound)
  sound:play()
end
-- Updates SFX list (remove all finished SFX).
function AudioManager:updateSFX()
  if self.sfx[1] then
    self.sfx:conditionalRemove(self.sfx[1].finished)
  end
end

---------------------------------------------------------------------------------------------------
-- BGM - General
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Stops current playing BGM (if any) and starts a new one.
-- @param(bgm : table) table with file's name (from audio/bgm folder), volume and pitch
-- @param(time : number) the duration of the fading transition
-- @param(wait : boolean) yields until the fading animation concludes
function AudioManager:playBGM(bgm, time, wait)
  if self.nextBGM then
    if self.BGM then
      self.BGM:stop()
    end
    self.BGM = self.nextBGM
  end
  if self.BGM then
    self.BGM:play()
  end
  self.nextBGM = Music(bgm.name, (bgm.volume or 100) / 100, (bgm.pitch or 100) / 100)
  self.nextBGM:play()
  self.nextBGM:setVolume(0)
  self:fade(time, wait)
end
-- @param(time : number) the duration of the fading transition
-- @param(wait : boolean) yields until the fading animation concludes
function AudioManager:resumeBGM(time, wait)
  if self.pausedBGM then
    self.BGM, self.nextBGM = self.nextBGM, self.BGM
    if self.BGM then
      self.BGM:resume()
    end
    if self.nextBGM then
      self.nextBGM:resume()
    end
    self.pausedBGM = false
    self:fade(time, wait)
  end
end

function AudioManager:pauseBGM(time, wait)
  self.pausedBGM = true
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
  if time and time > 0 then
    self.fadingSpeed = 1 / time * 60
    self.fading = 0
    if wait then
      self:waitForBGMFading()
    end
  else
    self.fadingSpeed = 0
    self.fading = 1
    self:updateBGMVolume()
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