
--[[===============================================================================================

Player
---------------------------------------------------------------------------------------------------
This is a special character that can me controlled by the player with keyboard.
It only exists for exploration fields.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')
local Character = require('core/objects/Character')
local Fiber = require('core/base/fiber/Fiber')
local FieldGUI = require('core/gui/field/FieldGUI')
local MoveAction = require('core/battle/action/MoveAction')
local Vector = require('core/math/Vector')

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
  self.inputDelay = 6 / 60
  self.moveInput = ActionInput(MoveAction({ far = 0, minh = 0, maxh = 0 }, 2), self)
  local troopData = Database.troops[SaveManager.current.playerTroopID]
  local leader = troopData.members[1]
  local data = {
    id = -1,
    key = 'player',
    battlerID = leader.battlerID,
    charID = leader.charID,
    animation = 'Idle',
    row = (dir or 270) / 45 }
  data.x, data.y, data.h = initTile:coordinates()
  Character.init(self, data)
end
-- Player's extra and base character properties.
function Player:initProperties(name, collisionTiles, colliderHeight)
  Character.initProperties(self, 'Player', collisionTiles, colliderHeight)
  self.inputOn = true
  self.dashSpeed = conf.dashSpeed
  self.walkSpeed = conf.walkSpeed
  self.speed = conf.walkSpeed
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- Coroutine that runs in non-battle fields.
function Player:fieldInputLoop()
  while true do
    if self:fieldInputEnabled() then
      self:checkFieldInput()
    end
    yield()
  end
end
-- Checks movement and interaction inputs.
function Player:checkFieldInput()
  if InputManager.keys['confirm']:isTriggered() then
    self:interact()
  elseif InputManager.keys['cancel']:isTriggered() then
    self:openGUI()
  elseif InputManager.keys['mouse1']:isPressing() then
    self:moveByMouse()
  elseif InputManager.keys['mouse2']:isTriggered() then
    self:openGUI()
  else
    local dx, dy, move = self:inputAxis()
    local dash = InputManager.keys['dash']:isPressing()
    local auto = SaveManager.config.autoDash
    if auto and not dash or not auto and dash then
      self.speed = self.dashSpeed
    else
      self.speed = self.walkSpeed
    end
    self:moveByKeyboard(dx, dy, move)
  end
end
-- Checks if field input is enabled.
-- @ret(boolean) true if enabled, false otherwise
function Player:fieldInputEnabled()
  local gui = GUIManager:isWaitingInput() or BattleManager.onBattle
  return not gui and self.inputOn and self.moveTime >= 1 and self.blocks == 0
end
-- @ret(number) x axis input
-- @ret(number) y axis input
-- @ret(boolean) True if it was pressed for long enough to move
function Player:inputAxis()
  local dx = InputManager:axisX(0, 0)
  local dy = InputManager:axisY(0, 0)
  if self.pressTime then
    if timer.getTime() - self.pressTime > self.inputDelay * self.walkSpeed / self.speed then
      self.pressX = dx
      self.pressY = dy
      if dx == 0 and dy == 0 then
        self.pressTime = nil
      end
      return self.pressX, self.pressY, true
    end
    if dx ~= 0 then
      self.pressX = dx
    end
    if dy ~= 0 then
      self.pressY = dy
    end
    return self.pressX, self.pressY, false
  else
    if dx ~= 0 or dy ~= 0 then
      self.pressTime = timer.getTime()
    end
    self.pressX = dx
    self.pressY = dy
    return dx, dy, false
  end
end

---------------------------------------------------------------------------------------------------
-- Mouse Movement
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Moves player to the mouse coordinate.
function Player:moveByMouse()
  local field = FieldManager.currentField
  for l = field.maxh, field.minh, -1 do
    local x, y = InputManager.mouse:fieldCoord(l)
    if field:exceedsBorder(x, y) then
      self:playIdleAnimation()
    elseif field:isGrounded(x, y, l) then
      if not self:tryPathMovement(field:getObjectTile(x, y, l)) then
        self:playIdleAnimation()
      end
      break
    end
  end
end
-- [COROUTINE] Tries to walk a path to the given tile.
-- @param(tile : ObjectTile) Destination tile.
function Player:tryPathMovement(tile)
  local range = { far = 0, minh = 0, maxh = 0 }
  local input = ActionInput(MoveAction(range, 12), self, tile)
  local path, fullPath = input.action:calculatePath(input)
  if not (path and fullPath) then
    range.far, range.minh, range.maxh = 1, 1, 1
    path, fullPath = input.action:calculatePath(input)
    if not (path and fullPath) then
      return false
    end
    path = path:addStep(tile, 1)
  end
  self.path = path:toStack()
  return self:consumePath()
end

---------------------------------------------------------------------------------------------------
-- Keyboard Movement
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Moves player depending on input.
-- @param(dx : number) input x
-- @param(dy : number) input y
function Player:moveByKeyboard(dx, dy, move)
  if dx ~= 0 or dy ~= 0 then
    self.path = nil
    local angle = coord2Angle(dx, dy)
    local result = move and (self:tryAngleMovement(angle)
      or self:tryAngleMovement(angle - 45)
      or self:tryAngleMovement(angle + 45))
    if not result then
      self:setDirection(angle)
      self:playIdleAnimation()
    end
  elseif self.path then
    self:consumePath()
  else
    self:playIdleAnimation()
  end
end
-- [COROUTINE] Tries to move in a given angle.
-- @param(angle : number) the angle in degrees to move
-- @ret(boolean) Returns false if the next angle must be tried, true to stop trying.
function Player:tryAngleMovement(angle)  
  local nextTile = self:frontTile(angle)
  if nextTile == nil then
    return false
  end
  return self:tryTileMovement(nextTile)
end

---------------------------------------------------------------------------------------------------
-- Movement
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Tries to move to the given tile.
-- @param(tile : ObjectTile) The destination tile.
-- @ret(number) Returns nil if the next angle must be tried, a number to stop trying.
function Player:tryTileMovement(tile)
  local ox, oy, oh = self:getTile():coordinates()
  local dx, dy, dh = tile:coordinates()
  local collision = FieldManager.currentField:collisionXYZ(self,
    ox, oy, oh, dx, dy, dh)
  if self.autoTurn then
    self:turnToTile(dx, dy)
  end
  if collision == nil then
    self.moveInput.target = tile
    local path, fullPath = self.moveInput.action:calculatePath(self.moveInput)
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
-- [COROUTINE] Walks the next tile of the path.
function Player:consumePath()
  if not self.path:isEmpty() then
    local tile = self.path:pop()
    if self:tryTileMovement(tile) == 0 then
      return true
    else
      self:interactTile(tile)
    end
  end
  self.path = nil
  return false
end

---------------------------------------------------------------------------------------------------
-- GUI
---------------------------------------------------------------------------------------------------

-- Opens game's main GUI.
function Player:openGUI()
  self:playIdleAnimation()
  AudioManager:playSFX(Sounds.menu)
  GUIManager:showGUIForResult(FieldGUI())
end

---------------------------------------------------------------------------------------------------
-- Interaction
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Interacts with whoever is the player looking at (if any).
function Player:interact()
  self:playIdleAnimation()
  local angle = self:getRoundedDirection()
  local interacted = self:interactTile(self:getTile()) or self:interactTile(self:frontTile())
    or self:interactAngle(angle - 45) or self:interactAngle(angle + 45)
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

---------------------------------------------------------------------------------------------------
-- Tile collision
---------------------------------------------------------------------------------------------------

-- Looks for collisions with characters in the given tile.
-- @param(tile : ObjectTile) The tile that the player is in or is trying to go.
-- @ret(boolean) True if there was any blocking collision, false otherwise.
function Player:collideTile(tile)
  if not tile then
    return false
  end
  for char in tile.characterList:iterator() do
    if char.collideScript then
      local event = {
        tile = tile,
        origin = self,
        dest = char }
      char:onCollide(event)
      if not char.passable then
        return true
      end
    end
  end
  return false
end

return Player