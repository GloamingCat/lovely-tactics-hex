
--[[===============================================================================================

GameManager
---------------------------------------------------------------------------------------------------
Handles basic game flow.

=================================================================================================]]

-- Imports
local TitleGUI = require('core/gui/start/TitleGUI')

-- Alias
local copyTable = util.table.deepCopy
local framerate = Config.screen.fpsLimit
local now = love.timer.getTime

local GameManager = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function GameManager:init()
  self.paused = false
  self.cleanTime = 300
  self.cleanCount = 0
  self.startedProfi = false
  self.frame = 0
  self.playTime = 0
  self.garbage = setmetatable({}, {__mode = 'v'})
  --PROFI = require('core/base/ProFi')
  --require('core/base/Stats').printStats()
end
-- Starts the game.
function GameManager:start(arg)
  self.fpsFont = ResourceManager:loadFont(Fonts.fps)
  self:setConfig(SaveManager.config)
  GUIManager.fiberList:fork(function()
    GUIManager:showGUIForResult(TitleGUI())
  end)
end
-- Sets current save.
function GameManager:setSave(save)
  self.playTime = save.playTime
  self.vars = copyTable(save.vars)
  TroopManager.troopData = copyTable(save.troops)
  TroopManager.playerTroopID = save.playerTroopID
  FieldManager.fieldData = copyTable(save.fields)
  FieldManager:loadTransition(save.playerTransition)
end
-- Sets the system config.
-- @param(config : table)
function GameManager:setConfig(config)
  AudioManager:setBGMVolume(config.volumeBGM)
  AudioManager:setSFXVolume(config.volumeSFX)
  GUIManager.fieldScroll = config.fieldScroll
  GUIManager.windowScroll = config.windowScroll
  InputManager.autoDash = config.autoDash
  InputManager.mouseEnabled = config.useMouse
  InputManager:setArrowMap(config.wasd)
  InputManager:setKeyMap(config.keyMap)
  ScreenManager:setMode(config.resolution)
end

---------------------------------------------------------------------------------------------------
-- Update
---------------------------------------------------------------------------------------------------

-- Game loop.
function GameManager:update(dt)
  local t = os.clock()  
  if not self.paused then
    if not FieldManager.paused then 
      FieldManager:update() 
    end
    if not GUIManager.paused then 
      GUIManager:update()
    end
    self.frame = self.frame + 1
  end
  if InputManager.keys['pause']:isTriggered() then
    self.paused = not self.paused
    SaveManager:onPause(self.paused)
  end
  if not AudioManager.paused then
    AudioManager:update()
  end
  if not InputManager.paused then
    InputManager:update()
  end
  self.cleanCount = self.cleanCount + 1
  if self.cleanCount >= self.cleanTime then
    self.cleanCount = 0
    if PROFI then
      self:updateProfi()
    end
    collectgarbage('collect')
  end
  if framerate then
    local sleep = 1 / framerate - (os.clock() - t)
    if sleep > 0 then
      love.timer.sleep(sleep)
    end
  end
end
-- Updates profi state.
function GameManager:updateProfi()
  if self.startedProfi then
    PROFI:stop()
    PROFI:writeReport('profi.txt')
    self.startedProfi = false
  else
    PROFI:start()
    self.startedProfi = true
  end
end

---------------------------------------------------------------------------------------------------
-- Draw
---------------------------------------------------------------------------------------------------

-- Draws game.
function GameManager:draw()
  drawCalls = 0
  ScreenManager:draw()
  love.graphics.setFont(self.fpsFont)
  --self:printStats()
  --self:printCoordinates()
  if self.paused then
    love.graphics.printf('PAUSED', 0, 0, ScreenManager:totalWidth(), 'right')
  end
end
-- Prints mouse tile coordinates on the screen.
function GameManager:printCoordinates()
  if not FieldManager.renderer then
    return
  end
  local tx, ty, th = InputManager.mouse:fieldCoord()
  love.graphics.print('(' .. tx .. ',' .. ty .. ',' .. th .. ')', 0, 12)
end
-- Prints FPS and draw call counts on the screen.
function GameManager:printStats()
  love.graphics.print(love.timer.getFPS())
  love.graphics.print(ScreenManager.drawCalls, 32, 0)
end

---------------------------------------------------------------------------------------------------
-- Pause
---------------------------------------------------------------------------------------------------

-- Pauses entire game.
-- @param(paused : boolean) pause value
-- @param(audio : boolean) also affect audio
-- @param(input : boolean) also affect input
function GameManager:setPaused(paused, audio, input)
  self.paused = paused
  if audio then
    AudioManager:setPaused(paused)
  end
  if input then
    InputManager:setPaused(paused)
  end
  if paused then
    self.playTime = self:currentPlayTime()
  end
  SaveManager.loadTime = now()
end
-- Gets the current total play time.
-- @ret(number) The time in seconds.
function GameManager:currentPlayTime()
  return self.playTime + (now() - SaveManager.loadTime)
end

---------------------------------------------------------------------------------------------------
-- Quit
---------------------------------------------------------------------------------------------------

-- Restarts the game from the TitleGUI.
function GameManager:restart()
  ScreenManager.shader = nil
  ScreenManager.renderers = {}
  FieldManager = require('core/field/FieldManager')()
  GUIManager = require('core/gui/GUIManager')()
  self:start()
end
-- Closes game.
function GameManager:quit()
  if _G.Fiber then
    _G.Fiber:wait(15)
  end
  love.event.quit()
end

return GameManager