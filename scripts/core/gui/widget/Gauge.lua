
--[[===============================================================================================

Gauge
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Imports
local SpriteGrid = require('core/graphics/SpriteGrid')
local Vector = require('core/math/Vector')

-- Alias
local round = math.round

local Gauge = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function Gauge:init(topLeft, width, height, value)
  self.topLeft = topLeft
  self.width = width - self:padding() * 2
  self.height = height - self:padding() * 2
  topLeft = topLeft + Vector(width / 2, height / 2, 1)
  self.frame = SpriteGrid(self:getFrame(), topLeft)
  self.frame:createGrid(GUIManager.renderer, width, height)
  self.bar = ResourceManager:loadAnimation(self:getBar(), GUIManager.renderer)
  self.bar.sprite.texture:setFilter('linear', 'linear')
  self:setValue(value or 1)
end

function Gauge:setValue(value)
  local w, h = self.bar.sprite:quadBounds()
  w = w * value
  self.bar.sprite:setQuad(0, 0, w, h)
  self.bar.sprite:setScale(value * self.width / w, self.height / h)
end

function Gauge:padding()
  return 1
end

function Gauge:getFrame()
  return Database.animations[Config.animations.gaugeFrameID]
end

function Gauge:getBar()
  return Database.animations[Config.animations.gaugeBarID]
end

---------------------------------------------------------------------------------------------------
-- Widget
---------------------------------------------------------------------------------------------------

function Gauge:updatePosition(pos)
  self.bar.sprite:setXYZ(round(pos.x + self.topLeft.x + self:padding()),
    round(pos.y + self.topLeft.y + self:padding()),
    pos.z + self.topLeft.z)
  self.frame:updatePosition(pos)
end

function Gauge:show()
  self.bar.sprite:setVisible(true)
  self.frame:setVisible(true)
end

function Gauge:hide()
  self.bar.sprite:setVisible(false)
  self.frame:setVisible(false)
end

function Gauge:update()
  self.bar:update()
end

function Gauge:destroy()
  self.bar:destroy()
  self.frame:destroy()
end

return Gauge