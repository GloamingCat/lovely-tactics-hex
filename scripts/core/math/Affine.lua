
--[[===============================================================================================

Affine
---------------------------------------------------------------------------------------------------
This module implements some functions to calculate affine transformations.

=================================================================================================]]

-- Alias
local min = math.min
local max = math.max
local rotate = math.rotate

local Affine = {}

---------------------------------------------------------------------------------------------------
-- Image Bounds
---------------------------------------------------------------------------------------------------

-- Transforms the bounding vertexes of the given transformable.
-- @param(t : Transformable)
-- @param(w : number) the width of the original rectangle
-- @param(h : number) the height of the original rectangle
-- @ret(table) an array of points (x in odd positions, y in even positions)
function Affine.getTransformedPoints(t, w, h)
  local p = {0, 0, w, 0, 0, h, w, h}
  for i = 1, #p, 2 do
    -- Apply offset
    p[i] = p[i] - t.offsetX
    p[i + 1] = p[i + 1] - t.offsetY
    -- Apply scale
    p[i] = p[i] * t.scaleX
    p[i + 1] = p[i + 1] * t.scaleY
    -- Apply rotation
    p[i], p[i + 1] = math.rotate(p[i], p[i + 1], t.rotation)
    -- Apply translation
    p[i] = p[i] + t.position.x
    p[i + 1] = p[i + 1] + t.position.y
  end
  return p
end
-- Gets the rectangle the represents the final bounding box of the given transformable.
-- @param(t : Transformable)
-- @param(w : number) the width of the original rectangle
-- @param(h : number) the height of the original rectangle
-- @ret(number) the x of the new rectangle
-- @ret(number) the y of the new rectangle
-- @ret(number) the width of the new rectangle
-- @ret(number) the height of the new rectangle
function Affine.getBoundingBox(t, w, h)
  local p = Affine.getTransformedPoints(t, w, h)
  local minx, maxx, miny, maxy = p[1], p[1], p[2], p[2]
  for i = 3, #p, 2 do
    minx = min(minx, p[i])
    maxx = max(maxx, p[i])
    miny = min(miny, p[i + 1])
    maxy = max(maxy, p[i + 1])
  end
  return minx, miny, maxx - minx, maxy - miny
end

---------------------------------------------------------------------------------------------------
-- Transform
---------------------------------------------------------------------------------------------------

-- Combines two transform tables (order does not matter).
-- @param(t1 : table) First transform table.
-- @param(t1 : table) Second transform table.
-- @ret(table) New transform table.
function Affine.combineTransforms(t1, t2)
  local t = {
    -- Space
    offsetX = t1.offsetX + t2.offsetX,
    offsetY = t1.offsetY + t2.offsetY,
    offsetDepth = t1.offsetDepth + t2.offsetDepth,
    scaleX = t1.scaleX * t2.scaleX / 100,
    scaleY = t1.scaleY * t2.scaleY / 100,
    rotation = t1.rotation + t2.rotation,
    -- Color
    red = t1.red * t2.red / 255,
    green = t1.green * t2.green / 255,
    blue = t1.blue * t2.blue / 255,
    alpha = t1.alpha * t2.alpha / 255,
    hue = t1.hue + t2.hue,
    saturation = t1.saturation * t2.saturation / 100,
    brightness = t1.brightness * t2.brightness / 100
  }
  return t
end

return Affine
