
--[[===============================================================================================

SimpleImage
---------------------------------------------------------------------------------------------------
A generic window content that stores a sprite with a given viewport.

=================================================================================================]]

-- Imports
local Sprite = require('core/graphics/Sprite')

-- Alias
local max = math.max
local min = math.min

local SimpleImage = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(sprite : Sprite) image's sprite
-- @param(x : number) the x position of the top-left corner inside window
-- @param(y : number) the y position of the top-left corner inside window
-- @param(depth : number) the depth of the image relative to window
-- @param(w : number) max width of the image
-- @param(h : number) max height of the image
function SimpleImage:init(sprite, x, y, depth, w, h)
  self.depth = depth
  self.width = w
  self.height = h
  self.x = x
  self.y = y
  self:setSprite(sprite)
end
-- Changes the sprite in the component.
function SimpleImage:setSprite(sprite)
  if self.sprite then
    self.sprite:destroy()
  end
  self.sprite = sprite
  if sprite then
    if (self.width or self.height) then
      self:centerSpriteQuad()
    else
      self.sx = self.x
      self.sy = self.y
    end
    self.sprite:setCenterOffset(self.depth or -1)
  end
end
-- Centers sprite inside the given rectangle.
function SimpleImage:centerSpriteQuad()
  local px, py, pw, ph = self.sprite.quad:getViewport()
  pw, ph = pw * self.sprite.scaleX, ph * self.sprite.scaleY
  local x, y = self.x or 0, self.y or 0
  local w, h = self.width or pw, self.height or ph
  local mw, mh = min(pw, w), min(ph, h)
  local mx, my = (pw - mw) / 2, (ph - mh) / 2
  self.sprite:setQuad(px + mx, py + my, mw / self.sprite.scaleX, mh / self.sprite.scaleY)
  self.sx = x + w / 2
  self.sy = y + h / 2
end

---------------------------------------------------------------------------------------------------
-- Window Content methods
---------------------------------------------------------------------------------------------------

-- Sets image position.
function SimpleImage:updatePosition(pos)
  if self.sprite then
    self.sprite:setXYZ(pos.x + self.sx, pos.y + self.sy, pos.z)
  end
end
-- Shows image.
function SimpleImage:show()
  if self.sprite then
    self.sprite:setVisible(true)
  end
end
-- Hides image.
function SimpleImage:hide()
  if self.sprite then
    self.sprite:setVisible(false)
  end
end
-- Destroys sprite.
function SimpleImage:destroy()
  if self.sprite then
    self.sprite:destroy()
  end
end

return SimpleImage
