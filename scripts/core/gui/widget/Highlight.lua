
--[[===============================================================================================

Hightlight
---------------------------------------------------------------------------------------------------
The light background that is visible behind the selected widget.

=================================================================================================]]

-- Imports
local SpriteGrid = require('core/graphics/SpriteGrid')
local Vector = require('core/math/Vector')
local Transformable = require('core/transform/Transformable')

local Highlight = class(Transformable)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(window : GridWindow)
function Highlight:init(window)
  Transformable.init(self)
  self.window = window
  local w, h = window:cellWidth() + 2, window:cellHeight() + 2
  self.spriteGrid = SpriteGrid(self:getSkin(), Vector(0, 0, 1))
  self.spriteGrid:createGrid(GUIManager.renderer, w, h)
  self.spriteGrid:updateTransform(self)
  self.displacement = Vector(w / 2 - 1, h / 2)
  window.content:add(self)
end
-- Window's skin.
-- @ret(table) 
function Highlight:getSkin()
  return Database.animations[Config.animations.highlightID]
end

---------------------------------------------------------------------------------------------------
-- Content methods
---------------------------------------------------------------------------------------------------

-- Updates position to the selected button.
function Highlight:updatePosition(wpos)
  local button = self.window:currentButton()
  if button then
    local pos = button:relativePosition()
    pos:add(wpos)
    pos:add(self.displacement)
    self:setPosition(pos)
    self.spriteGrid:updateTransform(self)
  else
    self.spriteGrid:setVisible(false)
  end
end
-- Shows sprite grid.
function Highlight:show()
  self.spriteGrid:setVisible(#self.window.matrix > 0)
end
-- Hides sprite grid.
function Highlight:hide()
  self.spriteGrid:setVisible(false)
end
-- Removes sprite grid.
function Highlight:destroy()
  self.spriteGrid:destroy()
end

return Highlight