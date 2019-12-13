
--[[===============================================================================================

Screen Utilities
---------------------------------------------------------------------------------------------------
Functions that are loaded from the EventSheet.

=================================================================================================]]

-- Alias
local deltaTime = love.timer.getDelta

local EventSheet = {}

---------------------------------------------------------------------------------------------------
-- Fading Effect
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(args.time : number) The duration of the fading in frames. Instantaneous if 0.
-- @param(args.wait : boolean) True to wait until the fading finishes.

-- Fades out the screen.
-- @param(args.renderer : Renderer) Camera to fade out. Field by default.
function EventSheet:fadeout(args)
  local renderer = args.renderer or FieldManager.renderer
  local speed = args.time and (60 / args.time) or 0
  renderer:fadeout(speed)
  if args.wait then
    _G.Fiber:waitUntil(function()
      return not renderer:colorizing()
    end)
  end
end
-- Fades in the screen.
-- @param(args.renderer : Renderer) Camera to fade in. Field by default.
function EventSheet:fadein(args)
  local renderer = args.renderer or FieldManager.renderer
  local speed = args.time and (60 / args.time) or 0
  renderer:fadein(speed)
  if args.wait then
    _G.Fiber:waitUntil(function()
      return not renderer:colorizing()
    end)
  end
end

---------------------------------------------------------------------------------------------------
-- Shader Effect
---------------------------------------------------------------------------------------------------

-- Shows the effect of a shader.
-- @param(args.name : string)
function EventSheet:shaderin(args)
  ScreenManager.shader = ResourceManager:loadShader(args.name)
  ScreenManager.shader:send('time', 0)
  local time = deltaTime()
  while time < 1 do
    ScreenManager.shader:send('time', time)
    coroutine.yield()
    time = time + deltaTime() * (args.speed or 1)
  end
  ScreenManager.shader:send('time', 1)
end
-- Hides the effect of a shader.
-- @param(args.name : string)
function EventSheet:shaderout(args)
  ScreenManager.shader:send('time', 1)
  local time = deltaTime()
  while time > 0 do
    ScreenManager.shader:send('time', time)
    coroutine.yield()
    time = time - deltaTime() * (args.speed or 1)
  end
  ScreenManager.shader:send('time', 0)
  ScreenManager.shader = nil
end

return Event
