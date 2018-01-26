
--[[===============================================================================================

IconList
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Imports
local SpriteGrid = require('core/graphics/SpriteGrid')

local IconList = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function IconList:init(topLeft, width, height, frameWidth, frameHeight)
  self.icons = {}
  self.frames = {}
  self.topLeft = topLeft
  self.width = width
  self.height = height
  self.frameWidth = frameWidth or 16
  self.frameHeight = frameHeight or 16
  self.visible = true
end

function IconList:setIcons(icons)
  self:destroy()
  self.icons = {}
  if not icons then
    return
  end
  local x, y = 0, 0
  for i = 1, #icons do
    local anim = ResourceManager:loadIconAnimation(icons[i], GUIManager.renderer)
    local _, _, w, h = anim.sprite:totalBounds()
    if x + w > self.width then
      if y + h > self.height then
        anim:destroy()
        break
      end
      if x > 0 then
        x = 0
        y = y + self.frameHeight - 1
      end
    end
    self.icons[i] = anim
    self.frames[i] = SpriteGrid(self:getSkin())
    self.frames[i]:createGrid(GUIManager.renderer, self.frameWidth, self.frameHeight)
    anim.x = x
    anim.y = y
    anim.sprite:setVisible(self.visible)
    x = x + self.frameWidth - 1
  end
end
-- Icon frame's skin.
-- @ret(table) 
function IconList:getSkin()
  return Database.animations[Config.animations.frameID]
end

---------------------------------------------------------------------------------------------------
-- Widget
---------------------------------------------------------------------------------------------------

function IconList:show()
  for i = 1, #self.icons do
    self.frames[i]:setVisible(true)
    self.icons[i]:show()
  end
  self.visible = true
end

function IconList:hide()
  for i = 1, #self.icons do
    self.frames[i]:setVisible(false)
    self.icons[i]:hide()
  end
  self.visible = false
end

function IconList:update()
  for i = 1, #self.icons do
    self.frames[i]:update()
    self.icons[i]:update()
  end
end

function IconList:destroy()
  for i = 1, #self.icons do
    self.frames[i]:destroy()
    self.icons[i]:destroy()
  end
end

function IconList:updatePosition(wpos)
  for i = 1, #self.icons do
    local x = wpos.x + self.topLeft.x + self.icons[i].x
    local y = wpos.y + self.topLeft.y + self.icons[i].y
    local z = wpos.z + self.topLeft.z - 1
    self.icons[i].sprite:setXYZ(x, y, z)
    self.frames[i]:updateTransform(self.icons[i].sprite)
    self.icons[i].sprite:setXYZ(x, y, z - 2)
  end
end

return IconList