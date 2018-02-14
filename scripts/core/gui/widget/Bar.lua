
--[[===============================================================================================

Bar
---------------------------------------------------------------------------------------------------
A bar meter.

=================================================================================================]]

-- Imports
local SpriteGrid = require('core/graphics/SpriteGrid')
local Vector = require('core/math/Vector')

-- Alias
local round = math.round

local Bar = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(topLeft : Vector) The position of the frame's top left corner.
-- @param(width : number) Total width of the frame.
-- @param(height : number) Height of the frame.
-- @param(value : number) Initial width of the bar (multiplier of frame width).
function Bar:init(topLeft, width, height, value)
  self.topLeft = topLeft
  self.width = width - self:padding() * 2
  self.height = height - self:padding() * 2
  topLeft = topLeft + Vector(width / 2, height / 2, 1)
  self.frame = SpriteGrid(self:getFrame(), topLeft)
  self.frame:createGrid(GUIManager.renderer, width, height)
  self.bar = ResourceManager:loadAnimation(self:getBar(), GUIManager.renderer)
  self.bar.sprite.texture:setFilter('linear', 'linear')
  self.quadWidth, self.quadHeight = self.bar.sprite:quadBounds()
  self:setValue(value or 1)
end
-- Sets the color of the bar.
-- @param(color : table) New color.
function Bar:setColor(color)
  self.bar.sprite:setColor(color)
end
-- Sets the width of the bar.
-- @param(value : number) Value from 0 to 1.
function Bar:setValue(value)
  local w = self.quadWidth * value
  local h = self.quadHeight
  self.bar.sprite:setQuad(0, 0, w, h)
  self.bar.sprite:setScale(value * self.width / w, self.height / h)
end
-- @ret(table) The frame padding.
function Bar:padding()
  return 1
end
-- @ret(table) The frame spritesheet from Database.
function Bar:getFrame()
  return Database.animations[Config.animations.gaugeFrameID]
end
-- @ret(table) The bar spritesheet from Database.
function Bar:getBar()
  return Database.animations[Config.animations.gaugeBarID]
end

---------------------------------------------------------------------------------------------------
-- Widget
---------------------------------------------------------------------------------------------------

-- Updates bar and frame positions.
function Bar:updatePosition(pos)
  self.bar.sprite:setXYZ(round(pos.x + self.topLeft.x + self:padding()),
    round(pos.y + self.topLeft.y + self:padding()),
    pos.z + self.topLeft.z)
  self.frame:updatePosition(pos)
end
-- Shows bar and frame.
function Bar:show()
  self.bar.sprite:setVisible(true)
  self.frame:setVisible(true)
end
-- Hides bar and frame.
function Bar:hide()
  self.bar.sprite:setVisible(false)
  self.frame:setVisible(false)
end
-- Updates bar animation.
function Bar:update()
  self.bar:update()
end
-- Destroys bar and frame.
function Bar:destroy()
  self.bar:destroy()
  self.frame:destroy()
end

return Bar