
--[[===============================================================================================

ResourceManager
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Imports
local Sprite = require('core/graphics/Sprite')
local Animation = require('core/graphics/Animation')
local Static = require('custom/animation/Static')

-- Alias
local newImage = love.graphics.newImage
local newFont = love.graphics.newFont
local newQuad = love.graphics.newQuad

-- Cache
local ImageCache = {}
local FontCache = {}

local ResourceManager = class()

---------------------------------------------------------------------------------------------------
-- Image
---------------------------------------------------------------------------------------------------

-- Overrides LÖVE's newImage function to use cache.
-- @param(path : string) image's path relative to main path
-- @ret(Image) to image store in the path
function ResourceManager:loadTexture(path)
  if type(path) == 'string' then
    path = 'images/' .. path:gsub('\\', '/')
    local img = ImageCache[path]
    if img then
      return img
    else
      img = newImage(path)
      img:setFilter('linear', 'nearest')
      ImageCache[path] = img
    end
  end
  return newImage(path)
end
-- @param(data : table) table with spritesheet's x, y, width, height, cols, rows and path to image
-- @param(texture : Image) (optional, may be loaded from data's image path)
-- @param(col : number) initial column (optional, 0 by default)
-- @param(row : number) initial row (optional, 0 by default)
-- @ret(Quad)
-- @ret(Image)
function ResourceManager:loadQuad(data, texture, col, row)
  texture = texture or self:loadTexture(data.path)
  local w = (data.width > 0 and data.width or texture:getWidth()) / data.cols
  local h = (data.height > 0 and data.height or texture:getHeight()) / data.rows
  col, row = col or 0, row or 0
  local quad = newQuad(data.x + col * w, data.y + row * h, w, h, texture:getWidth(), texture:getHeight())
  return quad, texture
end
-- Creates an animation from an animation data.
-- @param(data : table | string | number) animation's data or its ID or its image path
-- @param(dest : Renderer or Sprite)
-- @ret(Animation)
function ResourceManager:loadAnimation(data, dest)
  if type(data) == 'string' then
    if not dest.renderer then
      local texture = self:loadTexture(data)
      local w, h = texture:getWidth(), texture:getHeight()
      local quad = newQuad(0, 0, w, h, w, h)
      dest = Sprite(dest, texture, quad)
    end
    return Static(dest)
  elseif type(data) == 'number' then
    data = Database.animations[data]
  end
  if not dest.renderer then
    local quad, texture = self:loadQuad(data)
    dest = Sprite(dest, texture, quad)
    dest:setTransformation(data.transform)
  end
  local AnimClass = Animation
  if not data.animation then
    AnimClass = Static
  elseif data.animation.script.path ~= '' then
    AnimClass = require('custom/animation/' .. data.animation.script.path)
  end
  return AnimClass(dest, data)
end
-- Loads a sprite for an icon.
-- @param(icon : table) icon's data (animation ID, col and row)
-- @param(renderer : Renderer) renderer of the icon (FieldManager's or GUIManager's)
-- @ret(Sprite)
function ResourceManager:loadIcon(icon, renderer)
  local data = Database.animations[icon.id]
  local quad, texture = self:loadQuad(data, nil, icon.col, icon.row)
  local sprite = Sprite(renderer, texture, quad)
  sprite:setTransformation(data.transform)
  return sprite
end
-- Loads an icon as a single-sprite animation.
-- Loads a sprite for an icon.
-- @param(icon : table) icon's data (animation ID, col and row)
-- @param(renderer : Renderer) renderer of the icon (FieldManager's or GUIManager's)
-- @ret(Animation)
function ResourceManager:loadIconAnimation(icon, renderer)
  local sprite = self:loadIcon(icon, renderer)
  return Static(sprite)
end
-- Clears Image cache table.
-- Only use this if there is no other reference to the images.
function ResourceManager:clearImageCache()
  for k in pairs(ImageCache) do
    ImageCache[k] = nil
  end
end

---------------------------------------------------------------------------------------------------
-- Font
---------------------------------------------------------------------------------------------------

-- Overrides LÖVE's newFont function to use cache.
-- @param(data : table) {name, format, size, it, bold}
-- @ret(Font) 
function ResourceManager:loadFont(data)
  local path = data[1]
  if data[4] then
    path = path .. '_i'
  end
  if data[5] then
    path = path .. '_b'
  end
  path = path .. '.' .. data[2]
  local size = data[3]
  local key = path .. size
  local font = FontCache[key]
  if not font then
    font = newFont('fonts/' .. path, size * Fonts.scale)
    FontCache[key] = font
  end
  return font
end
-- Clears Font cache table.
-- Only use this if there is no other reference to the fonts.
function ResourceManager:clearFontCache()
  for k in pairs(FontCache) do
    FontCache[k] = nil
  end
end

return ResourceManager
