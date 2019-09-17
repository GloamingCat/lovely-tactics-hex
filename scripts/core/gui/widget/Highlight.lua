
--[[===============================================================================================

Hightlight
---------------------------------------------------------------------------------------------------
The light background that is visible behind the selected widget.

=================================================================================================]]

-- Imports
local Component = require('core/gui/Component')
local SpriteGrid = require('core/graphics/SpriteGrid')
local Vector = require('core/math/Vector')
local Transformable = require('core/math/transform/Transformable')

local Highlight = class(Component, Transformable)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(window : GridWindow) Parent window.
function Highlight:init(window)
  Transformable.init(self)
  local mx = window:colMargin() / 2 + 4
  local my = window:rowMargin() / 2 + 4
  local w, h = window:cellWidth() + mx, window:cellHeight() + my
  self.displacement = Vector(w / 2 - mx / 2, h / 2 - my / 2)
  Component.init(self, self.position, w, h)
  self.window = window
  window.content:add(self)
end
-- Overrides Component:createContent.
function Highlight:createContent(width, height)
  self.spriteGrid = SpriteGrid(self:getSkin(), Vector(0, 0, 1))
  self.spriteGrid:createGrid(GUIManager.renderer, width, height)
  self.spriteGrid:updateTransform(self)
  self.content:add(self.spriteGrid)
end
-- Window's skin.
-- @ret(table) Animation data.
function Highlight:getSkin()
  return Database.animations[Config.animations.highlight]
end

---------------------------------------------------------------------------------------------------
-- Content methods
---------------------------------------------------------------------------------------------------

-- Overrides Component:updatePosition.
-- Updates position to the selected button.
function Highlight:updatePosition(wpos)
  local button = self.window:currentWidget()
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
function Highlight:setVisible(value)
  Component.setVisible(self, value and #self.window.matrix > 0)
end

return Highlight
