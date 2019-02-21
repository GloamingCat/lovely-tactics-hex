
--[[===============================================================================================

Projectile
---------------------------------------------------------------------------------------------------
Abstraction of a projectile thrown during the use of a skill.

=================================================================================================]]

-- Alias
local min = math.min
local pixel2Tile = math.field.pixel2Tile
local tile2Pixel = math.field.tile2Pixel

local Projectile = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(skill : table) Skill's data.
-- @param(user : Object) The character throwing the projectile.
function Projectile:init(skill, user)
  self.height = user:getHeight(0, 0) / 2
  local i, j, h = user:frontTile():coordinates()
  local x, y, z = tile2Pixel(i, j, h + self.height)
  local row = skill.rotate and user.animation.row or 0
  local transform = nil -- TODO
  self:initAnimation(skill.projectileID, row, transform, x, y, z)
end
-- Creates animation.
-- @param(animID : number) Graphics animation.
-- @param(row : number) Row of the animation.
-- @param(transform : table) Skill transform data.
-- @param(x : number) Initial x in pixels.
-- @param(y : number) Initial y in pixels.
-- @param(z : number) Initial depth.
function Projectile:initAnimation(animID, row, transform, x, y, z)
  local animData = Database.animations[animID]
  assert(animData, 'Animation does not exist: ' .. animID)
  local animation = ResourceManager:loadAnimation(animData, FieldManager.renderer)
  animation.sprite:setXYZ(x, y, z)
  animation.sprite:setTransformation(animData.transform)
  if transform then
    animation.sprite:applyTransform(transform)
  end
  animation:setRow(row)
  FieldManager.updateList:add(animation)
  self.animation = animation
end

---------------------------------------------------------------------------------------------------
-- Movement
---------------------------------------------------------------------------------------------------

-- Starts the movement towards the target tile.
-- @param(target : ObjectTile) The target tile.
-- @param(speed : number) Speed in pixels per frame.
-- @ret(number) Duration of the movement in frames.
function Projectile:throw(target, speed, wait)
  local i, j, h = target:coordinates()
  local x, y, z = tile2Pixel(i, j, h + self.height)
  local d = self.animation.sprite.position:distance2DTo(x, y, z)
  local x0, y0, z0 = self.animation.sprite.position:coordinates()
  local fiber = FieldManager.fiberList:fork(function()
    local t = 0
    while t < 1 do
      t = min(t + love.timer.getDelta() * speed * 60 / d, 1)
      self.animation.sprite:setXYZ(x * t + x0 * (1 - t), y * t + y0 * (1 - t), z * t + z0 * (1 - t)) 
      coroutine.yield()
    end
    FieldManager.updateList:removeElement(self.animation)
    self.animation:destroy()
  end)
  if wait then
    fiber:waitForEnd()
  end
  return d / speed
end

return Projectile
