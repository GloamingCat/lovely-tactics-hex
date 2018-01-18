
--[[===============================================================================================

Text
---------------------------------------------------------------------------------------------------
A special type of Sprite which texture if a rendered text.

=================================================================================================]]

-- Imports
local Sprite = require('core/graphics/Sprite')
local TextParser = require('core/graphics/TextParser')
local TextRenderer = require('core/graphics/TextRenderer')

-- Alias
local lgraphics = love.graphics
local Quad = lgraphics.newQuad
local max = math.max
local min = math.min
local round = math.round

-- Constants
local defaultFont = Fonts.gui_default

local Text = class(Sprite)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(text : string) the rich text
-- @param(resources : table) table of resources used in text
-- @param(renderer : Renderer) the destination renderer of the sprite
-- @param(properties : table) the table with text properties:
--  (properties[1] : number) the width of the text box
--  (properties[2] : string) the align type (left, right or center) 
--    (optional, left by default)
--  (properties[3] : number) the max number of characters that will be shown 
--    (optional, no limit by default)
local old_init = Text.init
function Text:init(text, properties, renderer)
  old_init(self, renderer)
  self.maxWidth = properties[1]
  self.alignX = properties[2] or 'left'
  self.alignY = 'top'
  self.defaultFont = properties[3] or defaultFont
  self.maxchar = properties[4]
  self.text = text
  self.scaleX = 1
  self.scaleY = 1
  self.offsetX = 0
  self.offsetY = 0
  if text == nil or text == '' then
    self.lines = {}
  else
    self:setText(text)
  end
end
-- Sets/changes the text content.
-- @param(text : string) the rich text
-- @param(resources : table) table of resources used in text
function Text:setText(text)
  assert(text, 'Nil text')
  if text == '' then
    self.text = text
    self.lines = nil
    return
  end
  local maxWidth = self.maxWidth and self.maxWidth * Fonts.scale
  local fragments = TextParser.parse(text)
	local lines = TextParser.createLines(fragments, self.defaultFont, maxWidth)
  self.lines = TextRenderer.createLineBuffers(lines)
  local width, height = 0, 0
  for i = 1, #self.lines do
    width = max(self.lines[i].buffer:getWidth(), width)
    height = height + self.lines[i].height
  end
  self.quad = Quad(0, 0, width, height, width, height)
  self:recalculateBox()
  self.renderer.needsRedraw = true
end

---------------------------------------------------------------------------------------------------
-- Visibility
---------------------------------------------------------------------------------------------------

-- Checks if sprite is visible on screen.
-- @ret(boolean) true if visible, false otherwise
function Text:isVisible()
  return self.lines and self.visible
end

---------------------------------------------------------------------------------------------------
-- Bounds
---------------------------------------------------------------------------------------------------

-- Gets the total width in world coordinates.
-- @ret(number)
function Text:getWidth()
  local w = 0
  for i = 1, #self.lines do
    local line = self.lines[i]
    w = max(w, line.buffer:getWidth() * self.scaleX / Fonts.scale)
  end
  return w
end
-- Gets the total height in world coordinates.
-- @ret(number)
function Text:getHeight()
  local h = 0
  for i = 1, #self.lines do
    local line = self.lines[i]
    h = h + line.buffer:getHeight() / 1.5 * self.scaleY / Fonts.scale
  end
  return h
end

function Text:getQuadBounds()
  return self:getWidth(), self:getHeight()
end

---------------------------------------------------------------------------------------------------
-- Alignment
---------------------------------------------------------------------------------------------------

function Text:setMaxWidth(w)
  if self.maxWidth ~= w then
    self.maxWidth = w
    if self.alignX ~= 'left' then
      self.renderer.needsRedraw = true
    end
  end
end

function Text:setMaxHeight(h)
  if self.maxHeight ~= h then
    self.maxHeight = h
    if self.alignY ~= 'top' then
      self.renderer.needsRedraw = true
    end
  end
end

function Text:setAlignX(align)
  if self.alignX ~= align then
    self.alignX = align
    self.renderer.needsRedraw = true
  end
end

function Text:setAlignY(align)
  if self.alignY ~= align then
    self.alignY = align
    self.renderer.needsRedraw = true
  end
end

-- Gets the line offset in x according to the alingment.
-- @param(w : number) line's width
-- @ret(number) the x offset
function Text:alignOffsetX(w)
  if self.maxWidth then
    if self.alignX == 'right' then
      return self.maxWidth - w
    elseif self.alignX == 'center' then
      return (self.maxWidth - w) / 2
    end
  end
  return 0
end
-- Gets the text offset in y according to the alingment.
-- @param(h : number) text's height
-- @ret(number) the y offset
function Text:alignOffsetY(h)
  h = h or self:getHeight()
  if self.maxHeight then
    if self.alignY == 'bottom' then
      return self.maxHeight - h
    elseif self.alignY == 'center' then
      return (self.maxHeight - h) / 2
    end
  end
  return 0
end

---------------------------------------------------------------------------------------------------
-- Draw in screen
---------------------------------------------------------------------------------------------------

-- Called when renderer is iterating through its rendering list.
-- @param(renderer : Renderer)
function Text:draw(renderer)
  renderer:clearBatch()
  local sx, sy, lsx = self.scaleX / Fonts.scale, self.scaleY / Fonts.scale
  local x, y = 0, self:alignOffsetY()
  local r, g, b, a
  for i = 1, #self.lines do
    local line = self.lines[i]
    local w = line.buffer:getWidth() * sx
    if self.maxWidth and w > self.maxWidth then
      lsx = self.maxWidth / line.buffer:getWidth()
      x = -1
    else
      lsx = sx
      x = self:alignOffsetX(w) - 1
    end
    r, g, b, a = lgraphics.getColor()
    lgraphics.setColor(self.color.red, self.color.green, self.color.blue, self.color.alpha)
    lgraphics.draw(line.buffer, line.quad, self.position.x + x, self.position.y + y, 
      self.rotation, lsx, sy, self.offsetX, self.offsetY)
    lgraphics.setColor(r, g, b, a)
    y = y + line.height * sy
  end
end

return Text
