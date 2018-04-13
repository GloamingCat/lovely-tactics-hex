
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
local animID = Config.animations.arrowID

local GridScroll = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function GridScroll:init(window)
  window.content:add(self)
  self.speed = 5
  self.window = window
  local icon = {id = animID, col = 0, row = 0}
  self.right = ResourceManager:loadIcon(icon, GUIManager.renderer)
  icon.col = 1
  self.down = ResourceManager:loadIcon(icon, GUIManager.renderer)
  icon.row = 1
  self.left = ResourceManager:loadIcon(icon, GUIManager.renderer)
  icon.col = 0
  self.up = ResourceManager:loadIcon(icon, GUIManager.renderer)
end

---------------------------------------------------------------------------------------------------
-- Position
---------------------------------------------------------------------------------------------------

function GridScroll:updatePosition(pos)
  local w = self.window.width / 2 - self.window:hPadding() / 2
  local h = self.window.height / 2 - self.window:vPadding() / 2
  self.left:setXYZ(pos.x - w, pos.y, -1)
  self.right:setXYZ(pos.x + w, pos.y, -1)
  self.up:setXYZ(pos.x, pos.y - h, -1)
  self.down:setXYZ(pos.x, pos.y + h, -1)
  self:show()
end

---------------------------------------------------------------------------------------------------
-- Position
---------------------------------------------------------------------------------------------------

function GridScroll:update()
  if self.count then
    self.count = self.count + self.speed * delta()
    if self.count >= 1 then
      self.count = 0
      self.window:nextButton(self.dx, self.dy)
    end
  end
end

function GridScroll:onMouseMove(x, y)
  local w = self.window
  local dx, dy = 0, 0
  if x <= -w:hPadding() and self.left:isVisible() then
    dx = -1
  elseif x >= w:hPadding() and self.right:isVisible() then
    dx = 1
  end
  if y <= -w:vPadding() and self.up:isVisible() then
    dy = -1
  elseif y >= w:vPadding() and self.down:isVisible() then
    dy = 1
  end
  if dx ~= 0 or dy ~= 0 then
    self.count = self.count or 1
    self.dx = dx
    self.dy = dy
  else
    self.count = nil
  end
end

---------------------------------------------------------------------------------------------------
-- Content methods
---------------------------------------------------------------------------------------------------

function GridScroll:show()
  local w = self.window
  --local col = w:actualColCount() - w:colCount()
  --self.left:setVisible(w.offsetCol > 0)
  --self.right:setVisible(w.offsetCol < col)
  local row = w:actualRowCount() - w:rowCount()
  self.up:setVisible(w.offsetRow > 0)
  self.down:setVisible(w.offsetRow < row)
end

function GridScroll:hide()
  self.right:setVisible(false)
  self.up:setVisible(false)
  self.down:setVisible(false)
  self.left:setVisible(false)
end

function GridScroll:destroy()
  self.right:destroy()
  self.up:destroy()
  self.down:destroy()
  self.left:destroy()
end

return GridScroll