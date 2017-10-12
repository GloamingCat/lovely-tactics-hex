
--[[===============================================================================================

Player
---------------------------------------------------------------------------------------------------
This is a special character that can me controlled by the player with keyboard.
It only exists for exploration fields.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local Character = require('core/objects/Character')
local Fiber = require('core/fiber/Fiber')
local MainGUI = require('core/gui/field/MainGUI')

-- Alias
local timer = love.timer
local coord2Angle = math.coord2Angle
local tile2Pixel = math.field.tile2pixel
local yield = coroutine.yield

-- Constants
local conf = Config.player
local tg = math.field.tg

local Player = class(Character)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides BaseCharacter:init.
function Player:init(initTile, dir)
  self.blocks = 0
  self.dashSpeed = conf.dashSpeed
  self.walkSpeed = conf.walkSpeed
  self.inputDelay = 4 / 60
  local troopData = Database.troops[SaveManager.current.playerTroopID]
  local leader = troopData.current[1]
  local data = {
    id = -1,
    key = 'player',
    battlerID = leader.battlerID,
    charID = leader.charID,
    anim = 'Idle',
    direction = dir or 270 }
  data.x, data.y, data.h = initTile:coordinates()
  Character.init(self, data)
end
-- Player's extra and base character properties.
function Player:initializeProperties(name, collisionTiles, colliderHeight)
  Character.initializeProperties(self, 'Player', collisionTiles, colliderHeight)
  self.inputOn = true
  self.speed = conf.walkSpeed
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- Overrides CharacterBase:update.
-- Checks movement and interaction inputs.
function Player:checkFieldInput()
  while true do
    if self:fieldInputEnabled() then
      if InputManager.keys['confirm']:isTriggered() then
        self:interact()
      elseif InputManager.keys['cancel']:isTriggered() then
        self:openGUI()
      else
        local dx, dy, dir = self:inputAxis()
        if InputManager.keys['dash']:isPressing() then
          self.speed = self.dashSpeed
        else
          self.speed = self.walkSpeed
        end
        self:moveByInput(dx, dy, dir)
      end
    end
    yield()
  end
end
-- Checks if field input is enabled.
-- @ret(boolean) true if enabled, false otherwise
function Player:fieldInputEnabled()
  local gui = GUIManager:isWaitingInput() or BattleManager.onBattle
  return not gui and self.inputOn and self.moveTime >= 1 and self.blocks == 0
end
-- [COROUTINE] Moves player depending on input.
-- @param(dx : number) input x
-- @param(dy : number) input y
function Player:moveByInput(dx, dy, dir)
  if dx ~= 0 or dy ~= 0 then
    if dir then
      local dir = math.coord2Angle(dx, dy)
      self:setDirection(dir)
      return
    end
    if self.autoAnim then
      if self.speed < conf.dashSpeed then
        self:playAnimation(self.walkAnim)
      else
        self:playAnimation(self.dashAnim)
      end
    end
    local moved = self:tryMovement(dx, dy)
    if not moved then
      if self.autoAnim then
        self:playAnimation(self.idleAnim)
      end
      if self.autoTurn then
        local dir = math.coord2Angle(dx, dy)
        self:setDirection(dir)
      end
      self:adjustToTile()
    end
  else
    if self.autoAnim then
      self:playAnimation(self.idleAnim)
    end
  end
end
-- @ret(number) x axis input
-- @ret(number) y axis input
-- @ret(boolean) true if it was not pressed for long enough to move
function Player:inputAxis()
  local dx = InputManager:axisX(0, 0)
  local dy = InputManager:axisY(0, 0)
  if self.pressTime then
    if timer.getTime() - self.pressTime < self.inputDelay then
      if dx ~= 0 then
        self.pressX = dx
      end
      if dy ~= 0 then
        self.pressY = dy
      end
      if dx == 0 and dy == 0 then
        self.pressTime = nil
      end
      return self.pressX, self.pressY, true
    elseif dx == 0 and dy == 0 then
      self.pressTime = nil
    end
    return dx, dy
  else
    if dx ~= 0 or dy ~= 0 then
      self.pressTime = timer.getTime()
      self.pressX = dx
      self.pressY = dy
    end
    return dx, dy, true
  end
end

---------------------------------------------------------------------------------------------------
-- Movement
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Moves player with keyboard input (a complete tile).
-- @param(dx : number) input x
-- @param(dy : number) input y
-- @ret(boolean) true if player actually moved, false otherwise
function Player:tryMovement(dx, dy)
  local angle = coord2Angle(dx, dy)
  return self:tryAngleMovement(angle) or 
    self:tryAngleMovement(angle - 45) or 
    self:tryAngleMovement(angle + 45)
end
-- [COROUTINE] Tries to move in a given angle.
-- @param(angle : number) the angle in degrees to move
-- @ret(boolean) returns false if the next angle must be tried, true to stop trying
function Player:tryAngleMovement(angle)  
  local nextTile = self:frontTile(angle)
  if nextTile == nil then
    return false
  end
  local ox, oy, oh = self:getTile():coordinates()
  local dx, dy, dh = nextTile:coordinates()
  local collision = FieldManager.currentField:collisionXYZ(self,
    ox, oy, oh, dx, dy, dh)
  if collision ~= nil then
    if collision ~= 3 then -- not a character
      return false
    else
      if self.autoAnim then
        self:playAnimation(self.idleAnim)
      end
      if self.autoTurn then
        self:turnToTile(dx, dy) -- character
      end
      self:collideTile(nextTile)
      return true
    end
  else
    if nextTile.transition then
      self:teleport(nextTile.transition)
    end
    local autoAnim = self.autoAnim
    self.autoAnim = false
    self:walkToTile(dx, dy, dh, false)
    self.autoAnim = autoAnim
    self:collideTile(nextTile)
    return true
  end
  return false
end

---------------------------------------------------------------------------------------------------
-- Tile collision
---------------------------------------------------------------------------------------------------

function Player:collideTile(tile)
  if not tile then
    return false
  end
  self.blocks = self.blocks + 1
  for char in tile.characterList:iterator() do
    if char.collideScript then
      local event = {
        param = char.collideScript.param,
        tile = tile,
        origin = self,
        dest = char }
      char:onCollide(event)
      return true
    end
  end
  self.blocks = self.blocks - 1
end

function Player:teleport(transition)

end

---------------------------------------------------------------------------------------------------
-- GUI
---------------------------------------------------------------------------------------------------

-- Opens game's main GUI.
function Player:openGUI()
  GUIManager:showGUIForResult(MainGUI())
end

---------------------------------------------------------------------------------------------------
-- Interaction
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Interacts with whoever is the player looking at (if any).
function Player:interact()
  self.blocks = self.blocks + 1
  local angle = self:getRoundedDirection()
  local interacted = self:interactTile(self:getTile()) or self:interactTile(self:frontTile())
    or self:interactAngle(angle - 45) or self:interactAngle(angle + 45)
  self.blocks = self.blocks - 1
  return interacted
end
-- Tries to interact with any character in the given tile.
-- @param(tile : ObjectTile) 
-- @ret(boolean) true if the character interacted with someone, false otherwise
function Player:interactTile(tile)
  if not tile then
    return false
  end
  for i = #tile.characterList, 1, -1 do
    local char = tile.characterList[i]
    if char ~= self and char.interactScript ~= nil then
      local event = {
        param = char.interactScript.param,
        tile = tile,
        origin = self,
        dest = char }
      char:onInteract(event)
      return true
    end
  end
  return false
end
-- Tries to interact with any character in the tile looked by the given direction
function Player:interactAngle(angle)
  local nextTile = self:frontTile(angle)
  return self:interactTile(nextTile)
end

return Player