
--[[===============================================================================================

IconList
---------------------------------------------------------------------------------------------------
A list of icons to the drawn in a given rectangle.
Commonly used to show status icons in windows.

=================================================================================================]]

-- Imports
local SpriteGrid = require('core/graphics/SpriteGrid')

local IconList = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(topLeft : Vector) Position of the top left corner.
-- @param(width : number) The max width.
-- @param(height : number) The max height.
-- @param(frameWidth : number) The width of each icon (optional, 16 by default).
-- @param(frameHeight : number) The height of each icon (optional, 16 by default).
function IconList:init(topLeft, width, height, frameWidth, frameHeight)
  self.icons = {}
  self.frames = {}
  self.topLeft = topLeft
  self.width = width
  self.height = height
  self.frameWidth = frameWidth or 16
  self.frameHeight = frameHeight or 16
  self.frameID = Config.animations.frameID
  self.visible = true
end
-- Sets the content of this list.
-- @param(icons : table) Array of icon tables (id, col and row).
function IconList:setIcons(icons)
  self:destroy()
  local frameSkin = self.frameID >= 0 and Database.animations[self.frameID]
  self.icons = {}
  self.frames = frameSkin and {}
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
    if frameSkin then
      self.frames[i] = SpriteGrid(frameSkin)
      self.frames[i]:createGrid(GUIManager.renderer, self.frameWidth, self.frameHeight)
    end
    anim.x = x
    anim.y = y
    anim.sprite:setVisible(self.visible)
    x = x + self.frameWidth - 1
  end
end

---------------------------------------------------------------------------------------------------
-- Widget
---------------------------------------------------------------------------------------------------

-- Shows each icon.
function IconList:show()
  for i = 1, #self.icons do
    if self.frames then
      self.frames[i]:setVisible(true)
    end
    self.icons[i]:show()
  end
  self.visible = true
end
-- Hides each icon.
function IconList:hide()
  for i = 1, #self.icons do
    if self.frames then
      self.frames[i]:setVisible(false)
    end
    self.icons[i]:hide()
  end
  self.visible = false
end
-- Updates each icon animation.
function IconList:update()
  for i = 1, #self.icons do
    if self.frames then
      self.frames[i]:update()
    end
    self.icons[i]:update()
  end
end
-- Destroys each icon.
function IconList:destroy()
  for i = 1, #self.icons do
    if self.frames then
      self.frames[i]:destroy()
    end
    self.icons[i]:destroy()
  end
end
-- Updates each icon's position.
-- @param(wpos : Vector) Parent position.
function IconList:updatePosition(wpos)
  for i = 1, #self.icons do
    local x = wpos.x + self.topLeft.x + self.icons[i].x
    local y = wpos.y + self.topLeft.y + self.icons[i].y
    local z = wpos.z + self.topLeft.z - 1
    self.icons[i].sprite:setXYZ(x, y, z)
    if self.frames then
      self.frames[i]:updateTransform(self.icons[i].sprite)
    end
    self.icons[i].sprite:setXYZ(x, y, z - 2)
  end
end

return IconList