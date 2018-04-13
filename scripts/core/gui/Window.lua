
--[[===============================================================================================

Window
---------------------------------------------------------------------------------------------------
Provides the base for windows.
Every content element for the window must have all the following methods:
  show
  hide
  updatePosition(pos) (optional)
  update (optional)
  destroy

=================================================================================================]]

-- Imports
local Transformable = require('core/math/transform/Transformable')
local Vector = require('core/math/Vector')
local SpriteGrid = require('core/graphics/SpriteGrid')
local List = require('core/base/datastruct/List')

-- Alias
local floor = math.floor

local Window = class(Transformable)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(GUI : GUI) parent GUI
-- @param(width : number) total width in pixels (if nil, must be set later)
-- @param(height : number) total height in pixels (if nil, must be set later)
-- @param(position : Vector) the position of the center of the window 
--  (optional, center of the screen by default)
function Window:init(GUI, width, height, position)
  Transformable.init(self, position)
  self.GUI = GUI
  self.speed = 10
  self.spriteGrid = (not self.noSkin) and SpriteGrid(self:getSkin(), Vector(0, 0, 10))
  self.content = List()
  self.width = width
  self.height = height
  self.active = false
  self:insertSelf()
  self:createContent(width, height)
  self:setPosition(position or Vector(0, 0, 0))
  self:setVisible(false)
  self.lastOpen = true
end
-- Creates all content elements.
-- By default, only creates the skin.
function Window:createContent(width, height)
  self.width = width
  self.height = height
  if self.spriteGrid then
    self.spriteGrid:createGrid(GUIManager.renderer, width, height)
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Updates all content elements.
function Window:update()
  Transformable.update(self)
  if self.spriteGrid then
    self.spriteGrid:update()
  end
  for c in self.content:iterator() do
    if c.update then
      c:update()
    end
  end
end
-- Updates all content element's position.
function Window:updatePosition()
  if self.spriteGrid then
    self.spriteGrid:updatePosition(self.position)
  end
  for c in self.content:iterator() do
    if c.updatePosition then
      c:updatePosition(self.position)
    end
  end
end
-- Erases content.
function Window:destroy()
  if self.spriteGrid then
    self.spriteGrid:destroy()
  end
  for c in self.content:iterator() do
    c:destroy()
  end
end
-- Sets this window as the active one.
function Window:activate()
  self.GUI:setActiveWindow(self)
end
-- Activates/deactivates window.
-- @param(value : boolean) true to activate, false to deactivate
function Window:setActive(value)
  self.active = value
end
function Window:isInside(x, y)
  local w = self.width / 2
  local h = self.height / 2
  return x >= -w and x <= w and y >= -h and y <= h
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Sets the window to fully open or fully closed.
-- @param(value : boolean) true to open it, false to hide
function Window:setVisible(value)
  if value then
    self:showContent()
    self:setScale(self.scaleX, 1)
    self.open = true
    self.lastOpen = true
    self.closed = false
  else
    self:hideContent()
    self:setScale(self.scaleX, 0)
    self.lastOpen = false
    self.open = false
    self.closed = true
  end
end
-- Sets this window's position.
-- @param(position : Vector) new position
function Window:setXYZ(...)
  Transformable.setXYZ(self, ...)
  self:updatePosition()
end
-- Scales this window.
-- @param(sx : number) scale in axis x
-- @param(sy : number) scale in axis y
function Window:setScale(sx, sy)
  Transformable.setScale(self, sx, sy)
  if self.spriteGrid then
    self.spriteGrid:updateTransform(self)
  end
end
-- Changes the window's size.
-- It recreates all contents.
function Window:resize(w, h)
  w, h = w or self.width, h or self.height
  if w ~= self.width or h ~= self.height then
    self.width = w
    self.height = h
    if self.spriteGrid then
      self.spriteGrid:createGrid(GUIManager.renderer, w, h)
      self:setPosition(self.position)
    end
  end
end
-- Window's skin.
-- @ret(table) 
function Window:getSkin()
  return Database.animations[Config.animations.windowSkinID]
end
-- Horizontal padding.
function Window:hPadding()
  return 8
end
-- Vertical padding.
function Window:vPadding()
  return 8
end

---------------------------------------------------------------------------------------------------
-- Show/hide
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Opens this window.
function Window:show()
  if self.scaleY >= 1 then
    return
  end
  self.closed = false
  self.lastOpen = true
  self:scaleTo(self.scaleX, 1, self.speed, true)
  if self.scaleY >= 1 then
    self.open = true
    self:showContent()
  end
end
-- [COROUTINE] Closes this window.
function Window:hide(gui)
  if self.scaleY <= 0 then
    return
  end
  self.lastOpen = gui
  self.open = false
  self:hideContent()
  self:scaleTo(self.scaleX, 0, self.speed, true)
  if self.scaleX >= 1 then
    self.closed = true
  end
end
-- Inserts this window in the GUI's list.
function Window:insertSelf()
  if not self.GUI.windowList:contains(self) then
    self.GUI.windowList:add(self)
  end
end
-- Removes this window from the GUI's list.
function Window:removeSelf()
  self.GUI.windowList:removeElement(self)
end

---------------------------------------------------------------------------------------------------
-- Content
---------------------------------------------------------------------------------------------------

-- Shows all content elements.
function Window:showContent()
  for c in self.content:iterator() do
    if c.updatePosition then
      c:updatePosition(self.position)
    end
    c:show()
  end
end
-- Hides all content elements.
function Window:hideContent()
  for c in self.content:iterator() do
    c:hide()
  end
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- Checks if player pressed any GUI button.
-- By default, only checks the "cancel" key.
function Window:checkInput()
  local x, y = InputManager.mouse:guiCoord()
  x, y = x - self.position.x, y - self.position.y
  if InputManager.keys['confirm']:isTriggered() then
    self:onConfirm()
  elseif InputManager.keys['cancel']:isTriggered() then
    self:onCancel()
  elseif InputManager.keys['next']:isTriggered() then
    self:onNext()
  elseif InputManager.keys['prev']:isTriggered() then
    self:onPrev()
  elseif InputManager.mouse.moved then
    self:onMouseMove(x, y)
  elseif InputManager.keys['mouse1']:isTriggered() then
    self:onClick(1, x, y)
  elseif InputManager.keys['mouse2']:isTriggered() then
    self:onClick(2, x, y)
  else
    local dx, dy = InputManager:ortAxis(0.5, 0.0625)
    if dx ~= 0 or dy ~= 0 then
      self:onMove(dx, dy)
    end
  end
end
-- Called when player presses "confirm" key.
-- By default, only sets the result to 1.
function Window:onConfirm()
  self.result = 1
end
-- Called when player presses "cancel" key.
-- By default, only dets the result to 0.
function Window:onCancel()
  self.result = 0
end
-- Callod when player presses arrows.
function Window:onMove(dx, dy)
end
-- Called when player presses "next" key.
function Window:onNext()
end
-- Called when player presses "prev" key.
function Window:onPrev()
end
-- Called when player presses a mouse button.
function Window:onClick(button, x, y)
  if button == 1 then
    if self:isInside(x, y) then
      self:onConfirm()
    end
  else
    self:onCancel()
  end
end
-- Called when player moves mouse.
function Window:onMouseMove(x, y)
end

return Window
