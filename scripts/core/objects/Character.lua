
--[[===============================================================================================

Character
---------------------------------------------------------------------------------------------------
This class provides general functions to be called by fibers. 
The [COUROUTINE] functions must ONLY be called from a fiber.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')
local CharacterBase = require('core/objects/CharacterBase')
local MoveAction = require('core/battle/action/MoveAction')
local Projectile = require('core/battle/Projectile')

-- Alias
local mathf = math.field
local max = math.max
local time = love.timer.getDelta
local tile2Pixel = math.field.tile2Pixel

local Character = class(CharacterBase)

---------------------------------------------------------------------------------------------------
-- Animation
---------------------------------------------------------------------------------------------------

-- Plays animation for when character is knocked out.
-- @ret(Animation) The animation that started playing.
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
  return self:playAnimation(self.koAnim)
end

---------------------------------------------------------------------------------------------------
-- Movement
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Tries to move in a given angle.
-- @param(angle : number) The angle in degrees to move.
-- @ret(boolean) Returns false if the next angle must be tried, true to stop trying.
function Character:tryAngleMovement(angle)  
  local nextTile = self:frontTile(angle)
  if nextTile == nil then
    return false
  end
  return self:tryTileMovement(nextTile)
end
-- [COROUTINE] Tries to move to the given tile.
-- @param(tile : ObjectTile) The destination tile.
-- @ret(number) Returns nil if the next angle must be tried, a number to stop trying.
function Character:tryTileMovement(tile)
  local ox, oy, oh = self:getTile():coordinates()
  local dx, dy, dh = tile:coordinates()
  local collision = FieldManager.currentField:collisionXYZ(self,
    ox, oy, oh, dx, dy, dh)
  if self.autoTurn then
    self:turnToTile(dx, dy)
  end
  if collision == nil then
    local input = ActionInput(MoveAction(mathf.centerMask, 2), self, tile)
    local path, fullPath = input.action:calculatePath(input)
    if path and fullPath then
      self:playMoveAnimation()
      local autoAnim = self.autoAnim
      self.autoAnim = false
      self:walkToTile(dx, dy, dh, false)
      self.autoAnim = autoAnim
      self:collideTile(tile)
      return 0
    end
  end
  self:playIdleAnimation()
  if collision == 3 then -- character
    self:collideTile(tile)
    return 1
  else
    return nil
  end
end
-- [COROUTINE] Tries to walk a path to the given tile.
-- @param(tile : ObjectTile) Destination tile.
-- @param(pathLength : number) Maximum length of path.
-- @ret(boolean) True if the character walked the full path.
function Character:tryPathMovement(tile, pathLength)
  local input = ActionInput(MoveAction(mathf.neighborMask, pathLength), self, tile)
  local path, fullPath = input.action:calculatePath(input)
  if not (path and fullPath) then
    return false
  end
  path = path:addStep(tile, 1)
  self.path = path:toStack()
  return self:consumePath()
end
-- [COROUTINE] Walks the next tile of the path.
-- @ret(boolean) True if character walked to the next tile, false if collided.
-- @ret(ObjectTile) The last tile in the path (nil if path was empty).
function Character:consumePath()
  local tile = nil
  if not self.path:isEmpty() then
    tile = self.path:pop()
    if self:tryTileMovement(tile) == 0 then
      return true, tile
    else
      self:collideTile(tile)
    end
  end
  self.path = nil
  return false, tile
end

---------------------------------------------------------------------------------------------------
-- Skill (user)
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Executes the intro animations (load and cast) for skill use.
-- @param(target : ObjectTile) The target tile of the skill.
-- @param(skill : table) Skill data from database.
-- @ret(number) The duration of the animation.
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
-- @ret(number) The duration of the animation.
function Character:castSkill(skill, dir, target)
  -- Forward step
  if skill.stepOnCast then
    self:walkInAngle(self.castStep or 6, dir)
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
-- @param(origin : ObjectTile) The original tile of the character.
-- @param(skill : table) Skill data from database.
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
-- @param(skill : Skill) The skill used.
-- @param(origin : ObjectTile) The tile of the skill user.
-- @param(results : table) Results of the skill.
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
-- @param(path : Path) The path that the battler just walked.
function Character:onMove(path)
  self.steps = self.steps - path.totalCost
  self.battler.statusList:callback('Move', self, path)
end

return Character
