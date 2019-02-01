
--[[===============================================================================================

WindowCursor
---------------------------------------------------------------------------------------------------
A cursor for button windows.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')

local WindowCursor = class()

---------------------------------------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(window : GridWindow) cursor's window
function WindowCursor:init(window)
  self.window = window
  self.paused = false
  local animData = Database.animations[Config.animations.cursor]
  self.anim = ResourceManager:loadAnimation(animData, GUIManager.renderer)
  self.anim.sprite:setTransformation(animData.transform)
  self.anim.sprite:setVisible(false)
  local x, y, w, h = self.anim.sprite.quad:getViewport()
  self.displacement = Vector(-w / 2, window:cellHeight() / 2)
  self.hideOnDeactive = true
  window.content:add(self)
end

---------------------------------------------------------------------------------------------------
-- Content methods
---------------------------------------------------------------------------------------------------

-- Updates animation.
function WindowCursor:update()
  if self.window.active and not self.paused then
    self.anim:update()
  end
end
-- Updates position to the selected button.
function WindowCursor:updatePosition(wpos)
  local button = self.window:currentWidget()
  if button then
    local pos = button:relativePosition()
    pos:add(wpos)
    pos:add(self.displacement)
    self.anim.sprite:setPosition(pos)
  else
    self.anim.sprite:setVisible(false)
  end
end
-- Shows sprite.
function WindowCursor:show()
  local active = not self.hideOnDeactive or self.window.active
  self.anim.sprite:setVisible(active and #self.window.matrix > 0)
end
-- Hides sprite.
function WindowCursor:hide()
  self.anim.sprite:setVisible(false)
end
-- Removes sprite.
function WindowCursor:destroy()
  self.anim:destroy()
end

return WindowCursor
