
--[[===============================================================================================

GridScroll
---------------------------------------------------------------------------------------------------
Four arrows to navigate a GridWindow.

=================================================================================================]]

-- Imports
local Sprite = require('core/graphics/Sprite')

-- Alias
local Image = love.graphics.newImage
local delta = love.timer.getDelta

-- Constants
local animID = Config.animations.arrow

local GridScroll = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(window : GridWindow) Parent window.
function GridScroll:init(window)
  window.content:add(self)
  self.speed = 5
  self.window = window
  local icon = {id = animID, col = 1, row = 0}
  self.down = ResourceManager:loadIcon(icon, GUIManager.renderer)
  icon.col, icon.row = 0, 1
  self.up = ResourceManager:loadIcon(icon, GUIManager.renderer)
end

---------------------------------------------------------------------------------------------------
-- Position
---------------------------------------------------------------------------------------------------

-- Updates the position of each arrow.
-- @param(pos : Vector) The position of the window.
function GridScroll:updatePosition(pos)
  local h = self.window.height / 2 - self.window:paddingY() / 2
  self.up:setXYZ(pos.x, pos.y - h, -1)
  self.down:setXYZ(pos.x, pos.y + h, -1)
  self:show()
end

---------------------------------------------------------------------------------------------------
-- Position
---------------------------------------------------------------------------------------------------

-- Updates scroll count.
function GridScroll:update()
  if self.count then
    local speed = self.speed * GUIManager.windowScroll * 2 / 100
    self.count = self.count + speed * delta()
    if self.count >= 1 then
      self.count = 0
      self.window:nextWidget(0, self.dy)
    end
  end
end
-- Called when player moves the mouse.
-- @param(x : number) Position x relative to the center of the window.
-- @param(y : number) Position y relative to the center of the window.
function GridScroll:onMouseMove(x, y)
  local w = self.window
  local dy = 0
  if y <= -w:paddingY() and self.up:isVisible() then
    dy = -1
  elseif y >= w:paddingY() and self.down:isVisible() then
    dy = 1
  end
  if dy ~= 0 then
    self.count = self.count or 1
    self.dy = dy
  else
    self.count = nil
  end
end

---------------------------------------------------------------------------------------------------
-- Content methods
---------------------------------------------------------------------------------------------------

-- Shows the arrows.
function GridScroll:show()
  local w = self.window
  local row = w:actualRowCount() - w:rowCount()
  self.up:setVisible(w.offsetRow > 0)
  self.down:setVisible(w.offsetRow < row)
end
-- Hides the arrows.
function GridScroll:hide()
  self.up:setVisible(false)
  self.down:setVisible(false)
end
-- Destroys the arrows.
function GridScroll:destroy()
  self.up:destroy()
  self.down:destroy()
end

return GridScroll