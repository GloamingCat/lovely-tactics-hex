
--[[===============================================================================================

GameManager
---------------------------------------------------------------------------------------------------
Handles basic game flow.

=================================================================================================]]

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
  --PROFI = require('core/base/ProFi')
  --require('core/base/Stats').printStats()
end
-- Starts the game.
function GameManager:start(arg)
  self.fpsFont = ResourceManager:loadFont(Fonts.fps)
  SaveManager:newSave()
  FieldManager:loadTransition(SaveManager.current.playerTransition)
end

---------------------------------------------------------------------------------------------------
-- Update
---------------------------------------------------------------------------------------------------

-- Game loop.
function GameManager:update(dt)
  if not self.paused then
    if not FieldManager.paused then 
      FieldManager:update() 
    end
    if not GUIManager.paused then 
      GUIManager:update()
    end
  end
  if InputManager.keys['pause']:isTriggered() then
    self.paused = not self.paused
  end
  InputManager:update()
  self.cleanCount = self.cleanCount + 1
  if self.cleanCount >= self.cleanTime then
    self.cleanCount = 0
    if PROFI then
      self:updateProfi()
    end
    collectgarbage('collect')
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
  love.graphics.print(love.timer.getFPS())
  love.graphics.print(ScreenManager.drawCalls, 24, 0)
  --[[
  local pos = InputManager.mouse.position
  local wx, wy = FieldManager.renderer:screen2World(pos.x, pos.y)
  local tx, ty = math.field.pixel2Tile(wx, wy, -wy)
  tx, ty = math.round(tx), math.round(ty)
  love.graphics.print('(' .. tx .. ',' .. ty .. ')', 0, 12)
  ]]
  if self.paused then
    love.graphics.printf('PAUSED', 0, 0, ScreenManager:totalWidth(), 'right')
  end
end

return GameManager
