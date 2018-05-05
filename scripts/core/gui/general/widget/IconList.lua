
--[[===============================================================================================

IconList
---------------------------------------------------------------------------------------------------
A list of icons to the drawn in a given rectangle.
Commonly used to show status icons in windows.

=================================================================================================]]

-- Imports
local SimpleImage = require('core/gui/widget/SimpleImage')
local SpriteGrid = require('core/graphics/SpriteGrid')
local Vector = require('core/math/Vector')

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
  self.iconWidth = self.frameWidth
  self.iconHeight = self.frameHeight
  self.frameID = Config.animations.frameID
  self.visible = true
end
-- Sets the content of this list.
-- @param(icons : table) Array of sprites.
function IconList:setSprites(icons)
  self:destroy()
  local frameSkin = self.frameID >= 0 and Database.animations[self.frameID]
  self.icons = {}
  self.frames = frameSkin and {}
  if not icons then
    return
  end
  local x, y = 0, 0
  for i = 1, #icons do
    local sprite = icons[i]
    if x + self.frameWidth > self.width then
      if y + self.frameHeight > self.height then
        for j = i, icons do
          icons[j]:destroy()
        end
        break
      end
      if x > 0 then
        x = 0
        y = y + self.frameHeight - 1
      end
    end
    local pos = Vector(x + self.topLeft.x, y + self.topLeft.y, -1)
    if sprite then
      sprite:setVisible(self.visible)
      self.icons[i] = SimpleImage(sprite, pos.x - self.iconWidth / 2, pos.y - self.iconHeight / 2, 0, 
        self.iconWidth, self.iconHeight)
    else
      self.icons[i] = SimpleImage(nil, pos.x, pos.y, 0, self.iconWidth, self.iconHeight)
    end
    if frameSkin then
      self.frames[i] = SpriteGrid(frameSkin, pos)
      self.frames[i]:createGrid(GUIManager.renderer, self.frameWidth, self.frameHeight)
    end
    x = x + self.frameWidth - 1
  end
end
-- Sets the content of this list.
-- @param(icons : table) Array of icon tables (id, col and row).
function IconList:setIcons(icons)
  local anims = {}
  for i = 1, #icons do
    anims[i] = ResourceManager:loadIcon(icons[i], GUIManager.renderer)
  end
  self:setSprites(anims)
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
    self.icons[i]:updatePosition(wpos)
    if self.frames then
      self.frames[i]:updatePosition(wpos)
    end
  end
end

return IconList