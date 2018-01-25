
--[[===============================================================================================

Character
---------------------------------------------------------------------------------------------------
This class provides general functions to be called by fibers. 
The [COUROUTINE] functions must ONLY be called from a fiber.

=================================================================================================]]

-- Imports
local CharacterBase = require('core/objects/CharacterBase')
local Vector = require('core/math/Vector')
local Stack = require('core/datastruct/Stack')
local Sprite = require('core/graphics/Sprite')
local PopupText = require('core/battle/PopupText')

-- Alias
local abs = math.abs
local max = math.max
local min = math.min
local round = math.round
local sqrt = math.sqrt
local time = love.timer.getDelta
local angle2Coord = math.angle2Coord
local tile2Pixel = math.field.tile2Pixel
local pixel2Tile = math.field.pixel2Tile
local len2D = math.len2D

-- Constants
local mhpName = Config.battle.attHP
local mspName = Config.battle.attSP
local speedLimit = (Config.player.dashSpeed + Config.player.walkSpeed) / 2
local castStep = 6
local castTime = 7.5

local Character = class(CharacterBase)

---------------------------------------------------------------------------------------------------
-- General Movement
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Walks to the given pixel point (x, y, d).
-- @param(x : number) coordinate x of the point
-- @param(y : number) coordinate y of the point
-- @param(z : number) the depth of the point
-- @param(collisionCheck : boolean) if it should check collisions
-- @ret(boolean) true if the movement was completed, false otherwise
function Character:walkToPoint(x, y, z, collisionCheck)
  local anim = self.walkAnim
  if self.speed >= speedLimit then
    anim = self.dashAnim
  end
  z = z or self.position.z
  x, y, z = round(x), round(y), round(z)
  if self.autoAnim then
    self:playAnimation(anim)
  end
  if self.autoTurn then
    self:turnToPoint(x, -z)
  end
  local distance = len2D(self.position.x - x, self.position.y - y, self.position.z - z)
  self.collisionCheck = collisionCheck
  self:moveTo(x, y, z, self.speed / distance, true)
  if self.autoAnim then
    self:playAnimation(self.idleAnim)
  end
  return self.position:almostEquals(x, y, z)
end
-- Walks a given distance in each axis.
-- @param(dx : number) the distance in axis x (in pixels)
-- @param(dy : number) the distance in axis y (in pixels)
-- @param(dz : number) the distance in depth (in pixels)
-- @param(collisionCheck : boolean) if it should check collisions
-- @ret(boolean) true if the movement was completed, false otherwise
function Character:walkDistance(dx, dy, dz, collisionCheck)
  local pos = self.position
  return self:walkToPoint(pos.x + dx, pos.y + dy, pos.z + dz, collisionCheck)
end
-- Walks the given distance in the given direction.
-- @param(d : number) the distance to be walked
-- @param(angle : number) the direction angle
-- @param(dz : number) the distance in depth
-- @param(collisionCheck : boolean) if it should check collisions
-- @ret(boolean) true if the movement was completed, false otherwise
function Character:walkInAngle(d, angle, dz, collisionCheck)
  local dx, dy = angle2Coord(angle or self:getRoundedDirection())
  dz = dz or -dy
  return self:walkDistance(dx * d, dy * d, dz * d, collisionCheck)
end
-- [COROUTINE] Walks to the center of the tile (x, y).
-- @param(x : number) coordinate x of the tile
-- @param(y : number) coordinate y of the tile
-- @param(h : number) the height of the tile
-- @param(collisionCheck : boolean) if it should check collisions
-- @ret(boolean) true if the movement was completed, false otherwise
function Character:walkToTile(x, y, h, collisionCheck)
  x, y, h = tile2Pixel(x, y, h or self:getTile().layer.height)
  return self:walkToPoint(x, y, h, collisionCheck)
end
-- [COROUTINE] Walks a distance in tiles defined by (dx, dy)
-- @param(dx : number) the x-axis distance
-- @param(dy : number) the y-axis distance
-- @param(h : number) the height of the tile
-- @param(collisionCheck : boolean) if it should check collisions
-- @ret(boolean) true if the movement was completed, false otherwise
function Character:walkTiles(dx, dy, dh, collisionCheck)
  local pos = self.position
  local x, y, h = pixel2Tile(pos.x, pos.y, pos.z)
  return self:walkToTile(x + dx, y + dy, h + (dh or 0), collisionCheck)
end

---------------------------------------------------------------------------------------------------
-- Path
---------------------------------------------------------------------------------------------------

-- Walks along the given path.
-- @param(path : Path) a path of tiles
-- @param(collisionCheck : boolean) if it shoudl check collisions
-- @ret(boolean) true if the movement was completed, false otherwise
function Character:walkPath(path, collisionCheck)
  local stack = Stack()
  for step in path:iterator() do
    stack:push(step)
  end
  stack:pop()
  local field = FieldManager.currentField
  while not stack:isEmpty() do
    local nextTile = stack:pop()
    local h = nextTile.layer.height
    if not self:walkToTile(nextTile.x, nextTile.y, h, collisionCheck) and collisionCheck then
      break
    end
  end
  self:moveToTile(path.lastStep)
end

---------------------------------------------------------------------------------------------------
-- Skill (user)
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Executes the intro animations (load and cast) for skill use.
-- @param(target : ObjectTile) the target of the skill
-- @param(skill : table) skill data from database
function Character:loadSkill(skill, dir)
  local minTime = 0
  -- Load animation (user)
  if skill.userAnim.load ~= '' then
    local anim = self:playAnimation(skill.userAnim.load)
    anim:setCol(0)
    anim.time = 0
    minTime = anim.duration
  end
  -- Load animation (effect on tile)
  if skill.battleAnim.loadID >= 0 then
    local mirror = skill.mirror and dir > 90 and dir <= 270
    local pos = self.position
    local anim = BattleManager:playBattleAnimation(skill.battleAnim.loadID, 
      pos.x, pos.y, pos.z - 1, mirror)
    minTime = max(minTime, anim.duration)
  end
  _G.Fiber:wait(minTime)
end
-- [COROUTINE] Plays cast animation.
-- @param(skill : Skill)
-- @param(dir : number) the direction of the cast
-- @param(tile : ObjectTile) target of the skill
-- @param(wait : boolean)
function Character:castSkill(skill, dir, tile, wait)
  -- Forward step
  if skill.userAnim.stepOnCast then
    local oldAutoTurn = self.autoTurn
    self.autoTurn = false
    self:walkInAngle(castStep, dir)
    self.autoTurn = oldAutoTurn
  end
  -- Cast animation (user)
  if skill.userAnim.cast ~= '' then
    local anim = self:playAnimation(skill.userAnim.cast)
    anim:setCol(0)
    anim.time = 0
  end
  -- Cast animation (effect on tile)
  if skill.battleAnim.castID >= 0 then
    local mirror = skill.mirror and dir > 90 and dir <= 270
    local x, y, z = tile2Pixel(tile:coordinates())
    local anim = BattleManager:playBattleAnimation(skill.battleAnim.castID,
      x, y, z - 1, mirror)
  end
  if wait then
    _G.Fiber:wait(castTime)
  end
end
-- [COROUTINE] Returns to original tile and stays idle.
-- @param(origin : ObjectTile) the original tile of the character
-- @param(skill : table) skill data from database
function Character:finishSkill(origin, skill)
  if skill.userAnim.stepOnCast then
    local x, y, z = tile2Pixel(origin:coordinates())
    if self.position:almostEquals(x, y, z) then
      return
    end
    local autoTurn = self.autoTurn
    self.autoTurn = false
    self:walkToPoint(x, y, z)
    self.autoTurn = autoTurn
    self:setXYZ(x, y, z)
  end
  self:playAnimation(self.idleAnim)
end

---------------------------------------------------------------------------------------------------
-- Skill (target)
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Plays damage animation and shows the result in a pop-up.
-- @param(skill : Skill) the skill used
-- @param(origin : ObjectTile) the tile of the skill user
function Character:damage(skill, origin, results)
  local currentTile = self:getTile()
  if currentTile ~= origin then
    self:turnToTile(origin.x, origin.y)
  end
  self:playAnimation(self.damageAnim, true)
  self:playAnimation(self.idleAnim)
  if not self.battler:isAlive() then
    self:playAnimation(self.koAnim, true)
  end
end

---------------------------------------------------------------------------------------------------
-- Turn callbacks
---------------------------------------------------------------------------------------------------

-- Callback for when a new turn begins.
function Character:onTurnStart(partyTurn)
  if self.AI and self.AI.onTurnStart then
    self.AI:onTurnStart(partyTurn)
  end
  self.battler.statusList:callback('TurnStart', self, partyTurn)
  if partyTurn then
    self.steps = self.battler.maxSteps()
  end
end
-- Callback for when a turn ends.
function Character:onTurnEnd(partyTurn)
  if self.AI and self.AI.onTurnEnd then
    self.AI:onTurnEnd(partyTurn)
  end
  self.battler.statusList:callback('TurnEnd', self, partyTurn)
end
-- Callback for when this battler's turn starts.
function Character:onSelfTurnStart()
  self.battler.statusList:callback('SelfTurnStart', self)
end
-- Callback for when this battler's turn ends.
function Character:onSelfTurnEnd(result)
  self.battler.statusList:callback('SelfTurnEnd', self, result)
end

---------------------------------------------------------------------------------------------------
-- Skill callbacks
---------------------------------------------------------------------------------------------------

-- Callback for when the character finished using a skill.
function Character:onSkillUse(input)
  self.battler.statusList:callback('SkillUse', input)
end
-- Callback for when the characters ends receiving a skill's effect.
function Character:onSkillEffect(input, results)
  self.battler.statusList:callback('SkillEffect', input, results)
end

---------------------------------------------------------------------------------------------------
-- Other callbacks
---------------------------------------------------------------------------------------------------

-- Callback for when the character moves.
-- @param(path : Path) the path that the battler just walked
function Character:onMove(path)
  self.steps = self.steps - path.totalCost
  self.battler.statusList:callback('Move', self, path)
end

return Character
