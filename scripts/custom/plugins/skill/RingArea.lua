
--[[===============================================================================================

RingArea
---------------------------------------------------------------------------------------------------
Allows a battle action to use a ring area instead of a grid mask. A ring is defined by the minimum 
distance, or the radius of the smallest circle - <near> value -, and the maximum distance, or the 
radius of the largest circle - <far> value. The ring is the set of tiles within these limits.
It is also possible to define the maximum and minimum height differences, <minh> and <maxh>.

-- Skill parameters:
The range of the skill is defined by <cast_far>, <cast_near>, <cast_minh> and <cast_maxh>.
The effect area of the skill is defined by <effect_far>, <effect_near>, <effect_minh> and 
<effect_maxh>.
If no <cast_> tag is defined, then the default cast mask is used. The same for the <effect_> tags.

Notes:
* If <near> is bigger than <far> value, the set is empty.
* If <far> and <near> are the same value X, the ring is the set of tiles that distantiates from
the center by exactly X.
* If <far> and <near> are 0, the set contains only the center tile.

=================================================================================================]]

-- Imports
local SkillAction = require('core/battle/action/SkillAction')

-- Alias
local mathf = math.field

---------------------------------------------------------------------------------------------------
-- SkillAction
---------------------------------------------------------------------------------------------------

-- Constructor.
-- Creates ring masks if parameters are set in the tags.
local SkillAction_init = SkillAction.init
function SkillAction:init(...)
  SkillAction_init(self, ...)
  local t = self.tags
  if t.cast_maxh or t.cast_minh or t.cast_far or t.cast_near then
    self.range = self:createRingMask(t.cast_far or '1', t.cast_near, t.cast_minh, t.cast_maxh)
  end
  if t.effect_maxh or t.effect_minh or t.effect_far or t.effect_near then
    self.area = self:createRingMask(t.effect_far, t.effect_near, t.effect_minh, t.effect_maxh)
  end
end
-- Creates a mask for the ring format.
-- @param(far : number) The radius of the largest circle (maximum distance).
-- @param(near : number) The radius of the smallest circle (minimum distance).
-- @param(minh : number) Minimum height difference (usually negative).
-- @param(minh : number) Minimum height difference (usually positive).
function SkillAction:createRingMask(far, near, minh, maxh)
  far = far and tonumber(far) or 0
  near = near and tonumber(near) or 0
  minh = minh and tonumber(minh) or 0
  maxh = maxh and tonumber(maxh) or 0
  local grid = mathf.radiusMask(far, minh, maxh)
  for i, j in mathf.radiusIterator(near - 1, far + 1, far + 1,
      far * 2 + 1, far * 2 + 1) do
    for h = 1, maxh - minh + 1 do
      grid[h][i][j] = false
    end
  end
  return { grid = grid,
    centerH = -minh + 1,
    centerX = far + 1,
    centerY = far + 1 }
end
