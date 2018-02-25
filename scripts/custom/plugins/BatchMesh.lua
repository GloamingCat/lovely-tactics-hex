
--[[===============================================================================================

BatchMesh
---------------------------------------------------------------------------------------------------
Uses a mesh to renderer sprites with different HSVs.

=================================================================================================]]

-- Alias
local lgraphics = love.graphics

local Renderer = require('core/graphics/Renderer')
local vertexFormat = { { 'vhsv', 'float', 3 } }

local Renderer_init = Renderer.init
function Renderer:init(size, ...)
  Renderer_init(self, size, ...)
  self.mesh = lgraphics.newMesh(vertexFormat, size * 4)
end
-- Draws current and clears.
function Renderer:clearBatch()
  if self.batch and self.toDraw.size > 0 then
    self.batch:setTexture(self.batchTexture)
    self:setMeshAttributes(self.toDraw)
    self.batch:attachAttribute('vhsv', self.mesh)
    lgraphics.draw(self.batch)
    self.batch:clear()
    self.toDraw.size = 0
  end
end
-- Updates vertices in the mesh.
function Renderer:setMeshAttributes(list)
  local n = list.size - 1
  for i = 0, n do
    local h, s, v = list[i + 1]:getHSV()
    local i4 = i * 4
    self.mesh:setVertex(i4 + 1, h, s, v)
    self.mesh:setVertex(i4 + 2, h, s, v)
    self.mesh:setVertex(i4 + 3, h, s, v)
    self.mesh:setVertex(i4 + 4, h, s, v)
  end
  self.mesh:setDrawRange(1, list.size * 4)
end

function Renderer:batchPossible(sprite)
  return sprite.texture == self.batchTexture
end