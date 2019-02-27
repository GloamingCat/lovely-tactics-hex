
--[[===============================================================================================

Character
---------------------------------------------------------------------------------------------------
This class provides general functions to be called by fibers. 
The [COUROUTINE] functions must ONLY be called from a fiber.

=================================================================================================]]

-- Imports
local CharacterBase = require('core/objects/CharacterBase')
local Projectile = require('core/battle/Projectile')

-- Alias
local max = math.max
local round = math.round
local time = love.timer.getDelta
local angle2Coord = math.angle2Coord
local tile2Pixel = math.field.tile2Pixel
local pixel2Tile = math.field.pixel2Tile
local len = math.len2D

-- Constants
local speedLimit = (Config.player.dashSpeed + Config.player.walkSpeed) / 2
local castStep = 6

local Character = class(CharacterBase)

---------------------------------------------------------------------------------------------------
-- Animation
---------------------------------------------------------------------------------------------------

-- Plays animation for when character is moving.
function Character:playMoveAnimation()
  if self.autoAnim then
    self:playAnimation(self.speed < speedLimit and self.walkAnim or self.dashAnim)
  end
end
-- Plays animation for when character is idle.
function Character:playIdleAnimation()
  if self.autoAnim then
    self:playAnimation(self.idleAnim)
  end
end

function Character:playKOAnimation()
  if self.party == TroopManager.playerParty then
    if Sounds.allyKO then
      AudioManager:playSFX(Sounds.allyKO)
    end
  else
    if Sounds.enemyKO then
      AudioManager:playSFX(Sounds.enemyKO)
    end
  end
  self:playAnimation(self.koAnim, true)
end

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
  z = z or self.position.z
  x, y, z = round(x), round(y), round(z)
  self:playMoveAnimation()
  local distance = len(self.position.x - x, self.position.y - y, self.position.z - z)
  self.collisionCheck = collisionCheck
  self:moveTo(x, y, z, self.speed / distance, true)
  self:playIdleAnimation()
  return self.position:almostEquals(x, y, z, 0.2)
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
function Character:walkPath(path, collisionCheck, autoTurn)
  local field = FieldManager.currentField
  local stack = path:toStack()
  while not stack:isEmpty() do
    local nextTile = stack:pop()
    local x, y, h = nextTile:coordinates()
    if autoTurn then
      self:turnToTile(x, y)
    end
    local moved = self:walkToTile(x, y, h, collisionCheck)
    if not moved and collisionCheck then
      return
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
-- @ret(number) the duration of the animation
function Character:loadSkill(skill, dir)
  local minTime = 0
  -- Load animation (user)
  if skill.userLoadAnim ~= '' then
    local anim = self:playAnimation(skill.userLoadAnim)
    anim:setIndex(1)
    anim.time = 0
    minTime = anim.duration
  end
  -- Load animation (effect on tile)
  if skill.loadAnimID >= 0 then
    local mirror = skill.mirror and dir > 90 and dir <= 270
    local pos = self.position
    local anim = BattleManager:playBattleAnimation(skill.loadAnimID, 
      pos.x, pos.y, pos.z - 1, mirror)
    minTime = max(minTime, anim.duration)
  end
  return minTime
end
-- [COROUTINE] Plays cast animation.
-- @param(skill : table) Skill's data.
-- @param(dir : number) The direction of the cast.
-- @param(tile : ObjectTile) Target of the skill.
-- @ret(number) The duration of the animation
function Character:castSkill(skill, dir, target)
  -- Forward step
  if skill.stepOnCast then
    self:walkInAngle(castStep, dir)
  end
  -- Cast animation (user)
  local minTime = 0
  if skill.userCastAnim ~= '' then
    local anim = self:playAnimation(skill.userCastAnim)
    anim:reset()
    minTime = anim.duration
  end
  -- Projectile
  if skill.projectileID >= 0 then
    _G.Fiber:wait(minTime)
    local projectile = Projectile(skill, self)
    projectile:throw(target, skill.speed or 10, true)
    minTime = 0
  end
  -- Cast animation (effect on tile)
  if skill.castAnimID >= 0 then
    local mirror = skill.mirror and dir > 90 and dir <= 270
    local x, y, z = tile2Pixel(target:coordinates())
    local anim = BattleManager:playBattleAnimation(skill.castAnimID,
      x, y, z - 1, mirror)
    minTime = max(minTime, anim.duration)
  end
  return minTime
end
-- [COROUTINE] Returns to original tile and stays idle.
-- @param(origin : ObjectTile) the original tile of the character
-- @param(skill : table) skill data from database
function Character:finishSkill(origin, skill)
  if skill.stepOnCast then
    local x, y, z = tile2Pixel(origin:coordinates())
    if self.position:almostEquals(x, y, z) then
      return
    end
    local autoTurn = self.autoTurn
    self:walkToPoint(x, y, z)
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
  local anim = self:playAnimation(self.damageAnim)
  anim:reset()
  _G.Fiber:wait(anim.duration)
  if self.battler:isAlive() then
    self:playAnimation(self.idleAnim)
  else
    self:playKOAnimation()
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
  self.battler.statusList:onTurnStart(self, partyTurn)
  if partyTurn then
    self.steps = self.battler.maxSteps()
  else
    self.steps = 0
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
-- Other callbacks
---------------------------------------------------------------------------------------------------

-- Callback for when the character moves.
-- @param(path : Path) the path that the battler just walked
function Character:onMove(path)
  self.steps = self.steps - path.totalCost
  self.battler.statusList:callback('Move', self, path)
end

return Character
