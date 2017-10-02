
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
        local dx = InputManager:axisX(0, 0)
        local dy = InputManager:axisY(0, 0)
        if InputManager.keys['dash']:isPressing() then
          self.speed = self.dashSpeed
        else
          self.speed = self.walkSpeed
        end
        self:moveByInput(dx, dy)
      end
    end
    yield()
  end
end
-- Checks if field input is enabled.
-- @ret(boolean) true if enabled, false otherwise
function Player:fieldInputEnabled()
  local gui = GUIManager:isWaitingInput()
  return not gui and self.inputOn and self.moveTime >= 1 and self.blocks == 0
end
-- [COROUTINE] Moves player depending on input.
-- @param(dx : number) input x
-- @param(dy : number) input y
function Player:moveByInput(dx, dy)
  if dx ~= 0 or dy ~= 0 then
    local autoAnim = self.autoAnim
    self.autoAnim = false
    if autoAnim then
      if self.speed < conf.dashSpeed then
        self:playAnimation(self.walkAnim)
      else
        self:playAnimation(self.dashAnim)
      end
    end
    local moved = self:tryMovement(dx, dy)
    if not moved then
      if autoAnim then
        self:playAnimation(self.idleAnim)
      end
      if self.autoTurn then
        local dir = math.coord2Angle(dx, dy)
        self:setDirection(dir)
      end
      self:adjustToTile()
    end
    self.autoAnim = autoAnim
  else
    if self.autoAnim then
      self:playAnimation(self.idleAnim)
    end
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
    self:tryAngleMovement(angle + 45) or 
    self:tryAngleMovement(angle - 45)
end
-- [COROUTINE] Tries to move in a given angle.
-- @param(angle : number) the angle in degrees to move
-- @ret(boolean) returns false if the next angle must be tried
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
      self:playAnimation(self.idleAnim)
      self:turnToTile(dx, dy) -- character
      return true
    end
  else
    self:walkToTile(dx, dy, dh, false)
    return true
  end
  return false
end

---------------------------------------------------------------------------------------------------
-- Interaction
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Interacts with whoever is the player looking at (if any).
function Player:interact()
  self.blocks = self.blocks + 1
  local tile = self:frontTile()
  if tile == nil then
    return
  end
  for i = #tile.characterList, 1, -1 do
    local char = tile.characterList[i]
    if char ~= self and char.interactScript ~= nil then
      local event = {
        param = char.interactScript.param,
        tile = tile,
        origin = self,
        dest = char }
      local path = 'character/' .. char.interactScript.path
      local fiber = FieldManager.fiberList:forkFromScript(path, event)
      fiber:execAll()
    end
  end
  self.blocks = self.blocks - 1
end
-- Opens game's main GUI.
function Player:openGUI()
  GUIManager:showGUIForResult(MainGUI())
end

return Player