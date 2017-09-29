
--[[===============================================================================================

TextRenderer
---------------------------------------------------------------------------------------------------
Module to parser a rich text string to generate table of fragments.

=================================================================================================]]

-- Alias
local lgraphics = love.graphics
local Quad = lgraphics.newQuad

-- Constants
local textShader = love.graphics.newShader('shaders/text.glsl')
textShader:send('outlineSize', Font.outlineSize / Font.scale)

local TextRenderer = {}

---------------------------------------------------------------------------------------------------
-- Final Buffer
---------------------------------------------------------------------------------------------------

function TextRenderer.createLineBuffers(lines, defaultFont)
  -- Previous graphics state
  local r, g, b, a = lgraphics.getColor()
  local shader = lgraphics.getShader()
  local canvas = lgraphics.getCanvas()
  local font = lgraphics.getFont()
  -- New graphics state
  lgraphics.setFont(defaultFont)
  lgraphics.setColor(255, 255, 255, 255)
  -- Render lines individually
	local renderedLines = {}
  for i = 1, #lines do
    lgraphics.setShader()
    local buffer = TextRenderer.createLineBuffer(lines[i])
    lgraphics.setShader(textShader)
    local shadedBuffer = TextRenderer.shadeBuffer(buffer)
    local w, h = shadedBuffer:getWidth(), shadedBuffer:getHeight()
    renderedLines[i] = {
      buffer = shadedBuffer,
      height = lines[i].height,
      quad = Quad(0, 0, w, h, w, h) }
	end
  -- Reset graphics state
  lgraphics.setColor(r, g, b, a)
  lgraphics.setFont(font)
  lgraphics.setShader(shader)
  lgraphics.setCanvas(canvas)
  return renderedLines
end
-- Renders texture with the shader in a buffer with the correct size.
-- @param(texture : Canvas) rendered text
-- @ret(Canvas) pre-shaded texture
function TextRenderer.shadeBuffer(texture)
  local w, h = texture:getWidth(), texture:getHeight()
  local newTexture = lgraphics.newCanvas(w, h)
  newTexture:setFilter('linear', 'nearest')
  lgraphics.setCanvas(newTexture)
  textShader:send('stepSize', { Font.outlineSize / w, Font.outlineSize / h })
  --lgraphics.setBlendMode('alpha', 'premultiplied')
  lgraphics.draw(texture)
  --lgraphics.setBlendMode('alpha')
  return newTexture
end

---------------------------------------------------------------------------------------------------
-- Individual buffers
---------------------------------------------------------------------------------------------------

-- @param(line : table) a list of text fragments
-- @ret(Canvas) rendered line
function TextRenderer.createLineBuffer(line)
  local buffer = lgraphics.newCanvas(line.width + Font.outlineSize * 2, line.height * 1.5)
  buffer:setFilter('linear', 'nearest')
  lgraphics.setCanvas(buffer)
  local x, y = Font.outlineSize, line.height
  for j = 1, #line do
    local fragment = line[j]
    local t = type(fragment.content)
    if t == 'table' then
      local c = fragment.content
      lgraphics.setColor(c.red, c.green, c.blue, c.alpha)
    elseif t == 'userdata' then
      lgraphics.setFont(fragment.content)
    else
      local fy = y - fragment.height
      if t == 'string' and fragment.content ~= '' then
        lgraphics.print(fragment.content, x, fy)
        x = x + fragment.width
      end
    end
  end
  return buffer
end

return TextRenderer
