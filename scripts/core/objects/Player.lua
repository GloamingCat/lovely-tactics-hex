
--[[===============================================================================================

Player
---------------------------------------------------------------------------------------------------
This is a special character that can me controlled by the player with keyboard or mouse.
It only exists in exploration fields, not in battle fields.

=================================================================================================]]

-- Imports
local Character = require('core/objects/Character')
local Fiber = require('core/fiber/Fiber')
local FieldGUI = require('core/gui/menu/FieldGUI')
local Vector = require('core/math/Vector')

-- Alias
local conf = Config.player
local coord2Angle = math.coord2Angle
local rand = love.math.random
local now = love.timer.getTime
local yield = coroutine.yield

local Player = class(Character)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides CharacterBase:init.
function Player:init(initTile, dir)
  self.blocks = 0
  self.inputDelay = 6 / 60
  self.stepCount = 0
  self.freq = 16
  self.varFreq = 0.1
  self.varPitch = 0.1
  self.varVolume = 0.2
  local troopData = Database.troops[TroopManager.playerTroopID]
  local leader = troopData.members[1]
  local data = {
    id = -1,
    key = 'player',
    battlerID = leader.battlerID,
    charID = leader.charID,
    animation = 'Idle',
    direction = dir or 270,
    scripts = {} }
  data.x, data.y, data.h = initTile:coordinates()
  Character.init(self, data)
end
-- Overrides CharacterBase:initProperties.
function Player:initProperties(name, collisionTiles, colliderHeight)
  Character.initProperties(self, name, collisionTiles, colliderHeight)
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
    local auto = InputManager.autoDash
    if auto and not dash or not auto and dash then
      self.speed = self.dashSpeed
    else
      self.speed = self.walkSpeed
    end
    self:moveByKeyboard(dx, dy, move)
  end
end
-- Checks if field input is enabled.
-- @ret(boolean) True if enabled, false otherwise.
function Player:fieldInputEnabled()
  return self.inputOn and self.blocks == 0 and not self:isBusy()
end
-- Checks if player is waiting for an action to finish, like a movement animation, 
--  GUI input or battle.
-- @ret(boolean) True if some action is running.
function Player:isBusy()
  return self.moveTime < 1 or GUIManager:isWaitingInput() or BattleManager.onBattle
end
-- Gets the keyboard move/turn input. 
-- @ret(number) The x-axis input.
-- @ret(number) The y-axis input.
-- @ret(boolean) True if it was pressed for long enough to move. 
--  If false, the character just turns to the input direction, but does not move.
function Player:inputAxis()
  local dx = InputManager:axisX(0, 0)
  local dy = InputManager:axisY(0, 0)
  if self.pressTime then
    if now() - self.pressTime > self.inputDelay * self.walkSpeed / self.speed then
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
      self.pressTime = now()
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
  local currentTile = self:getTile()
  for l = field.maxh, field.minh, -1 do
    local x, y = InputManager.mouse:fieldCoord(l)
    if field:exceedsBorder(x, y) then
      self:playIdleAnimation()
    elseif field:isGrounded(x, y, l) then
      local tile = field:getObjectTile(x, y, l)
      local interacted = (tile == currentTile or tile == self:frontTile()) 
        and self:interactTile(tile)
      local moved = not interacted and tile ~= currentTile and 
        self:tryPathMovement(tile, conf.pathLength or 12)
      if not moved then
        self:playIdleAnimation()
      end
      break
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Keyboard Movement
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Moves player depending on input.
-- @param(dx : number) The x-axis input.
-- @param(dy : number) The x-axis input.
-- @param(move : boolean) False if character is just turning to the given direction, true if it
--  must move.
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

---------------------------------------------------------------------------------------------------
-- Terrain
---------------------------------------------------------------------------------------------------

-- Overrides CharacterBase:update.
-- Plays terrain step sound.
function Player:update()
  Character.update(self)
  if self:moving() then
    self.stepCount = self.stepCount + self.speed / conf.walkSpeed * 60 * GameManager:frameTime()
    if self.stepCount > self.freq then
      local sounds = FieldManager.currentField:getTerrainSounds(self:tileCoordinates())
      if sounds and #sounds > 0 then
        local sound = sounds[rand(#sounds)]
        local pitch = sound.pitch * (rand() * self.varPitch * 2 - self.varPitch + 1)
        local volume = sound.volume * (rand() * self.varVolume * 2 - self.varVolume + 1)
        if sound then
          AudioManager:playSFX({name = sound.name, pitch = pitch, volume = volume})
        end
      end
      self.stepCount = self.stepCount - self.freq * (rand() * self.varFreq * 2 - self.varFreq + 1)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- GUI
---------------------------------------------------------------------------------------------------

-- Opens game's main GUI.
function Player:openGUI()
  self:playIdleAnimation()
  AudioManager:playSFX(Sounds.menu)
  GUIManager:showGUIForResult(FieldGUI(nil))
end

---------------------------------------------------------------------------------------------------
-- Interaction
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Interacts with whoever is the player looking at (if any).
-- @ret(boolean) True if the character interacted with someone, false otherwise.
function Player:interact()
  self:playIdleAnimation()
  local angle = self:getRoundedDirection()
  local interacted = self:interactTile(self:getTile()) or self:interactTile(self:frontTile())
    or self:interactAngle(angle - 45) or self:interactAngle(angle + 45)
  return interacted
end
-- Tries to interact with any character in the given tile.
-- @param(tile : ObjectTile) The tile where the interactable is.
-- @ret(boolean) True if the character interacted with someone, false otherwise.
function Player:interactTile(tile)
  if not tile then
    return false
  end
  for i = #tile.characterList, 1, -1 do
    local char = tile.characterList[i]
    if char ~= self and char:onInteract(tile) then
      return true
    end
  end
  return false
end
-- Tries to interact with any character in the tile looked by the given direction.
-- @ret(boolean) True if the character interacted with someone, false otherwise.
function Player:interactAngle(angle)
  local nextTile = self:frontTile(angle)
  return self:interactTile(nextTile)
end

return Player
