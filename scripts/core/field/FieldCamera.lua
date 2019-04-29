
--[[===============================================================================================

FieldCamera
---------------------------------------------------------------------------------------------------
The FieldCamera is a renderer with transform properties.

=================================================================================================]]

-- Imports
local Renderer = require('core/graphics/Renderer')

-- Alias
local tile2Pixel = math.field.tile2Pixel
local pixelCenter = math.field.pixelCenter
local sqrt = math.sqrt

local FieldCamera = class(Renderer)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function FieldCamera:init(...)
  self.images = {}
  Renderer.init(self, ...)
  self.fadeSpeed = 100 / 60
  self.cameraSpeed = 75
  self.cropMovement = true
end
-- Initializes field's foreground and background images.
-- @param(field : Field) Current field.
-- @param(images : table) Array of field's images.
function FieldCamera:addImages(images)
  local x, y = pixelCenter(FieldManager.currentField.sizeX, FieldManager.currentField.sizeY)
  for _, data in ipairs(images) do
    local sprite = ResourceManager:loadIcon(data, self)
    sprite:setVisible(data.visible)
    if data.foreground then
      sprite:setXYZ(x, y, self.minDepth)
    else
      sprite:setXYZ(x, y, self.maxDepth)
    end
    sprite.glued = data.glued
    self.images[data.name] = sprite
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Overrides Movable:setXYZ.
function FieldCamera:setXYZ(x, y, ...)
  Renderer.setXYZ(self, x, y, ...)
  for _, img in pairs(self.images) do
    if img.glued then
      img:setXYZ(x, y)
    end
  end
end
-- Overrides Movable:updateMovement.
function FieldCamera:updateMovement()
  if self.focusObject then
    self:setXYZ(self.focusObject.position.x, self.focusObject.position.y)
  else
    Renderer.updateMovement(self)
  end
end

---------------------------------------------------------------------------------------------------
-- Camera Movement
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Moves camera to the given tile.
-- @param(tile : ObjectTile) the destionation tile
-- @param(speed : number) the speed of the movement (optional, uses default speed)
-- @param(wait : boolean) flag to wait until the move finishes (optional, false by default)
function FieldCamera:moveToTile(tile, speed, wait)
  local x, y = tile2Pixel(tile:coordinates())
  self:moveToPoint(x, y, speed, wait)
end
-- [COROUTINE] Movec camera to the given object.
-- @param(obj : Object) the destination object
-- @param(speed : number) the speed of the movement (optional, uses default speed)
-- @param(wait : boolean) flag to wait until the move finishes (optional, false by default)
function FieldCamera:moveToObject(obj, speed, wait)
  self:moveToPoint(obj.position.x, obj.position.y, speed, wait)
end
-- Moves camera to the given pixel point.
-- @param(x : number) the pixel x
-- @param(y : nubmer) the pixel y
-- @param(obj : Object) the destination object
-- @param(speed : number) the speed of the movement (optional, uses default speed)
-- @param(wait : boolean) flag to wait until the move finishes (optional, false by default)
function FieldCamera:moveToPoint(x, y, speed, wait)
  self.focusObject = nil
  local dx = self.position.x - x
  local dy = self.position.y - y
  local distance = sqrt(dx * dx + dy * dy)
  speed = ((speed or self.cameraSpeed) + distance * 3)
  self:moveTo(x, y, 0, speed / distance, wait)
end

---------------------------------------------------------------------------------------------------
-- Camera Color
---------------------------------------------------------------------------------------------------

-- Fades the screen out (changes color multiplier to black). 
-- @param(speed : number) The speed of the fading (optional, uses default speed).
-- @param(wait : boolean) flag to wait until the fading finishes (optional, false by default)
function FieldCamera:fadeout(speed, wait)
  self:colorizeTo(0, 0, 0, 0, speed or self.fadeSpeed, wait)
end
-- Fades the screen in (changes color multiplier to white). 
-- @param(speed : number) the speed of the fading (optional, uses default speed)
-- @param(wait : boolean) flag to wait until the fading finishes (optional, false by default)
function FieldCamera:fadein(speed, wait)
  self:colorizeTo(255, 255, 255, 255, speed or self.fadeSpeed, wait)
end

return FieldCamera
