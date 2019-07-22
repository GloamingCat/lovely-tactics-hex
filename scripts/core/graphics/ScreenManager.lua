
--[[===============================================================================================

ScreenManager
---------------------------------------------------------------------------------------------------
ScreenManager stores info about screen's 
transformation (translation and scale).

Scaling types:
0 => cannot scale at all
1 => scale only by integer scalars
2 => scale by real scalars, but do not change width:height ratio
3 => scale freely

=================================================================================================]]

-- Alias
local lgraphics = love.graphics
local setWindowMode = love.window.setMode
local isFullScreen = love.window.getFullscreen
local round = math.round

-- Constants
local defaultScaleX = Config.screen.widthScale / 100
local defaultScaleY = Config.screen.heightScale / 100

local ScreenManager = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function ScreenManager:init()
  love.graphics.setDefaultFilter("nearest", "nearest")
  self.width = Config.screen.nativeWidth
  self.height = Config.screen.nativeHeight
  self.scalingType = 1
  self.scaleX = defaultScaleX
  self.scaleY = defaultScaleY
  self.offsetX = 0
  self.offsetY = 0
  self.canvas = lgraphics.newCanvas(self.width * self.scaleX, self.height * self.scaleY)
  self.renderers = {}
  self.drawCalls = 0
  self.mode = 1
end

---------------------------------------------------------------------------------------------------
-- Draw
---------------------------------------------------------------------------------------------------

-- Overrides love draw to count the calls.
local old_draw = love.graphics.draw
function love.graphics.draw(...)
  old_draw(...)
  _G.ScreenManager.drawCalls = _G.ScreenManager.drawCalls + 1
end
-- Draws game canvas.
function ScreenManager:draw()
  self.drawCalls = 0
  lgraphics.setCanvas(self.canvas)
  lgraphics.clear()
  for i = 1, #self.renderers do
    if self.renderers[i] then
      self.renderers[i]:draw()
    end
  end
  lgraphics.setCanvas()
  lgraphics.setShader(self.shader)
  lgraphics.draw(self.canvas, self.offsetX, self.offsetY)
end

---------------------------------------------------------------------------------------------------
-- Size
---------------------------------------------------------------------------------------------------

-- Scales the screen (deforms both field and GUI).
-- @param(x : number) the scale factor in axis x
-- @param(y : number) the scale factor in axis y
function ScreenManager:setScale(x, y, fullScreen)
  if self.scalingType == 0 then
    return
  elseif self.scalingType == 1 then
    x = round(x)
    y = x
  elseif self.scalingType == 2 then
    y = x
  end
  fullScreen = fullScreen or false
  y = y or x
  if x == self.scaleX and y == self.scaleY and fullScreen == isFullScreen() then
    return
  end
  self.scaleX = x
  self.scaleY = y
  self.offsetX = 0
  self.offsetY = 0
  self.canvas = lgraphics.newCanvas(self.width * x, self.height * y)
  setWindowMode(self.width * x, self.height * y, {fullscreen = fullScreen})
  for i = 1, #self.renderers do
    if self.renderers[i] then
      self.renderers[i]:resizeCanvas()
    end
  end
end
-- Width in world size.
function ScreenManager:totalWidth()
  return self.scaleX * self.width
end
-- Height in world size.
function ScreenManager:totalHeight()
  return self.scaleY * self.height
end

---------------------------------------------------------------------------------------------------
-- Mode
---------------------------------------------------------------------------------------------------

-- Sets window mode (windowd or fullscreen).
-- @param(mode : number) 1, 2, 3 are window modes, 4 is fullscreen.
function ScreenManager:setMode(mode)
  if mode == 4 then
    self:setFullScreen()
  else
    self:setScale(mode, mode)
  end
  self.mode = mode
end
-- Changes screen to window mode.
function ScreenManager:setWindowed()
  if isFullScreen() then
    self:setScale(defaultScaleX, defaultScaleY)
  end
end
-- Changes screen to full screen mode.
function ScreenManager:setFullScreen()
  if isFullScreen() then
    return
  end
  local modes = love.window.getFullscreenModes(1)
  local mode = modes[1]
  local scaleX = mode.width / self.width
  local scaleY = mode.height / self.height
  if self.scalingType == 1 or self.scalingType == 2 then
    scaleX = math.min(scaleX, scaleY)
    scaleY = scaleX
  end
  self:setScale(scaleX, scaleY, true)
  self.offsetX = round((mode.width - self.canvas:getWidth()) / 2)
  self.offsetY = round((mode.height - self.canvas:getHeight()) / 2)
end
-- Called when window receives/loses focus.
-- @param(f : boolean) True if screen received focus, false if lost.
function ScreenManager:onFocus(f)
  if f then
    ResourceManager:refreshImages()
    local renderers = _G.ScreenManager.renderers
    for i = 1, #renderers do
      if renderers[i] then
        renderers[i].needRedraw = true
      end
    end
  end
end

return ScreenManager
