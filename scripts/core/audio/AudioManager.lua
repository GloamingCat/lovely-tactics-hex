
--[[===============================================================================================

AudioManager
---------------------------------------------------------------------------------------------------
Stores and manages all sound objects in the game. 

=================================================================================================]]

-- Imports
local List = require('core/datastruct/List')
local Music = require('core/audio/Music')
local Sound = require('core/audio/Sound')

-- Alias
local yield = coroutine.yield
local max = math.max
local min = math.min

local AudioManager = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Initializes with no sound.
function AudioManager:init()
  -- BGM
  self.BGM = nil
  self.fading = 1
  self.fadingSpeed = 0
  self.volumeBGM = 100
  self.pitchBGM = 100
  self.pausedBGM = false
  -- SFX
  self.sfx = List()
  self.volumeSFX = 100
  self.pitchSFX = 100
  self.paused = false
  -- Default sounds
  self.titleTheme = Sounds.titleTheme
  self.battleTheme = Sounds.battleTheme
  self.victoryTheme = Sounds.victoryTheme
  self.gameoverTheme = Sounds.gameoverTheme
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Updates BGM and SFX audio.
function AudioManager:update()
  self:updateBGM()
  self:updateSFX()
end
-- Pauses/resumes all sounds.
-- @param(paused : boolean) True to paused, false to resume.
function AudioManager:setPaused(paused)
  self.paused = paused
  if self.BGM then
    self.BGM:setPaused(paused)
  end
  for i = 1, #self.sfx do
    self.sfx[i]:setPaused(paused)
  end
end

---------------------------------------------------------------------------------------------------
-- Volume
---------------------------------------------------------------------------------------------------

-- @ret(number) Volume multiplier for current BGM.
function AudioManager:getBGMVolume()
  return self.volumeBGM
end
-- @param(v : number) Volume multiplier for current BGM.
function AudioManager:setBGMVolume(v)
  self.volumeBGM = v
  if self.BGM then
    self.BGM:refreshVolume()
  end
end
-- @ret(number) Volume multiplier for current SFX.
function AudioManager:getSFXVolume()
  return self.volumeSFX
end
-- @param(v : number) Volume multiplier for current SFX.
function AudioManager:setSFXVolume(v)
  self.volumeSFX = v
  for i = 1, #self.sfx do
    self.sfx[i]:refreshVolume()
  end
end

---------------------------------------------------------------------------------------------------
-- Pitch
---------------------------------------------------------------------------------------------------

-- @ret(number) Pitch multiplier for current BGM.
function AudioManager:getBGMPitch()
  return self.pitchBGM
end
-- @param(p : number) Pitch multiplier for current BGM.
function AudioManager:setBGMPitch(p)
  self.pitchBGM = p
  if self.BGM then 
    self.BGM:refreshPitch()
  end
end
-- @ret(number) Pitch multiplier for current SFX.
function AudioManager:getSFXPitch()
  return self.pitchSFX
end
-- @param(p : number) Pitch multiplier for current SFX.
function AudioManager:setSFXPitch(p)
  self.pitchSFX = p
  for i = 1, #self.sfx do
    self.sfx[i]:refreshPitch()
  end
end

---------------------------------------------------------------------------------------------------
-- SFX
---------------------------------------------------------------------------------------------------

-- Insert a new SFX in the list and plays it.
-- @param(sfx : table) Table with file's name (from audio/sfx folder), volume and pitch.
function AudioManager:playSFX(sfx)
  local sound = Sound(sfx.name, sfx.volume or 100, sfx.pitch or 100)
  self.sfx:add(sound)
  sound:play()
end
-- Updates SFX list (remove all finished SFX).
function AudioManager:updateSFX()
  if self.sfx[1] then
    self.sfx:conditionalRemove(self.sfx[1].isFinished)
  end
end

---------------------------------------------------------------------------------------------------
-- BGM - General
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Stops current playing BGM (if any) and starts a new one.
-- @param(bgm : table) Table with file's name (from audio/bgm folder), volume and pitch.
-- @param(time : number) The duration of the fading transition.
-- @param(wait : boolean) Yields until the fading animation concludes.
function AudioManager:playBGM(bgm, time, wait)
  if self.BGM and self.BGM.name == bgm.name then
    return
  end
  self.pausedBGM = false
  if self.BGM then
    self.BGM:pause()
  end
  self.BGM = Music(bgm.name, bgm.volume or 100, bgm.pitch or 100, bgm.intro, bgm.loop)
  self.BGM:play()
  self:fadein(time, wait)
end
-- @param(time : number) The duration of the fading transition.
-- @param(wait : boolean) Yields until the fading animation concludes.
function AudioManager:resumeBGM(time, wait)
  if self.pausedBGM then
    if self.BGM then
      self.BGM:play()
    end
    self.pausedBGM = false
    self:fadein(time, wait)
  end
end
-- [COROUTINE] Paused current BGM.
-- @param(time : number) Fade-out time.
-- @param(wait : boolean) Wait until the end of the fading.
-- @ret(Music) Current playing BGM (if any).
function AudioManager:pauseBGM(time, wait)
  if self.BGM then
    self.pausedBGM = true
    self:fadeout(time, wait)
    return self.BGM
  end
end

---------------------------------------------------------------------------------------------------
-- BGM - Update
---------------------------------------------------------------------------------------------------

-- Updates fading and BGMs.
function AudioManager:updateBGM()
  if self.BGM then
    self.BGM:update()
  else
    return
  end
  if self.fadingSpeed > 0 and self.fading < 1 or self.fadingSpeed < 0 and self.fading > 0 then
    self.fading = min(1, max(0, self.fading + GameManager:frameTime() * self.fadingSpeed))
    self.BGM:refreshVolume()
  end
end

---------------------------------------------------------------------------------------------------
-- Fading
---------------------------------------------------------------------------------------------------

-- @param(time : number) The duration of the fading.
-- @param(wait : boolean) True to only return when the fading finishes.
function AudioManager:fadeout(time, wait)
  if time and time > 0 then
    self.fading = 1
    self.fadingSpeed = -60 / time
    if wait then
      self:waitForBGMFading()
    end
  else
    self.fading = 0
    self.fadingSpeed = 0
    if self.BGM then
      self.BGM:refreshVolume()
    end
  end
end
-- @param(time : number) The duration of the fading.
-- @param(wait : boolean) True to only return when the fading finishes.
function AudioManager:fadein(time, wait)
  if time and time > 0 then
    self.fading = 0
    self.fadingSpeed = 60 / time
    if wait then
      self:waitForBGMFading()
    end
  else
    self.fading = 1
    self.fadingSpeed = 0
    if self.BGM then
      self.BGM:refreshVolume()
    end
  end
end
-- [COROUTINE] Waits until the fading value is 1.
function AudioManager:waitForBGMFading()
  local fiber = _G.Fiber
  if self.fadingFiber then
    self.fadingFiber:interrupt()
  end
  self.fadingFiber = fiber
  while self.fading < 1 and self.fading > 0 do
    yield()
  end
  if fiber:running() then
    self.fadingFiber = nil
  end
end

return AudioManager
