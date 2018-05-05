
--[[===============================================================================================

InputManager
---------------------------------------------------------------------------------------------------
Stores relevant inputs for the game.

=================================================================================================]]

-- Imports
local GameKey = require('core/input/GameKey')
local GameMouse = require('core/input/GameMouse')

-- Alias
local max = math.max
local dt = love.timer.getDelta
local now = love.timer.getTime

local InputManager = class()

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Constructor.
function InputManager:init()
  self.usingKeyboard = true
  self.mouseEnabled = true
  self.mouse = GameMouse()
  self.keys = {}
  for k, v in pairs(KeyMap) do
    self.keys[v] = GameKey()
  end
  self.paused = false
end
-- Checks if player is using keyboard and updates all keys' states.
function InputManager:update()
  self.usingKeyboard = false
  for code, key in pairs(self.keys) do
    if key.pressState > 0 and not code:match('mouse') then
      self.usingKeyboard = true
    end
    key:update()
  end
  self.mouse:update()
end
-- Pauses / unpauses the input update.
function InputManager:setPaused(paused)
  self.paused = paused
end

---------------------------------------------------------------------------------------------------
-- Axis keys
---------------------------------------------------------------------------------------------------

-- Converts boolean key buttons to axis in [-1, 1].
-- @ret(number) the x-axis value
function InputManager:axisX(startGap, repeatGap, delay)
  if self.keys['left']:isPressingGap(startGap, repeatGap, delay)  then
    if self.keys['right']:isPressingGap(startGap, repeatGap, delay) then
      return 0
    else
      return -1
    end
  else
    if self.keys['right']:isPressingGap(startGap, repeatGap, delay) then
      return 1
    else
      return 0
    end
  end
end
-- Converts boolean key buttons to axis in [-1, 1].
-- @ret(number) the y-axis value
function InputManager:axisY(startGap, repeatGap, delay)
  if self.keys['up']:isPressingGap(startGap, repeatGap, delay) then
    if self.keys['down']:isPressingGap(startGap, repeatGap, delay) then
      return 0
    else
      return -1
    end
  else
    if self.keys['down']:isPressingGap(startGap, repeatGap, delay) then
      return 1
    else
      return 0
    end
  end
end
-- Return input axis.
-- @ret(number) the x-axis value
-- @ret(number) the y-axis value
function InputManager:axis(startGap, repeatGap)
  return self:axisX(startGap, repeatGap), self:axisY(startGap, repeatGap)
end
-- Return a forced "orthogonal" axis (x and y can't be both non-zero).
-- @ret(number) the x-axis value
-- @ret(number) the y-axis value
function InputManager:ortAxis(startGap, repeatGap, delay)
  local x = self:axisX(startGap, repeatGap, delay)
  local y = self:axisY(startGap, repeatGap, delay)
  if x ~= 0 and y ~= 0 then
    local xtime = max(self.keys['left'].pressTime, self.keys['right'].pressTime)
    local ytime = max(self.keys['down'].pressTime, self.keys['up'].pressTime)
    if xtime < ytime then
      return x, 0
    else
      return 0, y
    end
  else
    return x, y
  end
end

---------------------------------------------------------------------------------------------------
-- Keyboard
---------------------------------------------------------------------------------------------------

-- Called when player presses any key.
-- @param(code : string) the code of the key based on keyboard layout
-- @param(scancode : string) the code of the key
-- @param(isrepeat : boolean) if the call is a repeat
function InputManager:onPress(code, scancode, isrepeat)
  code = KeyMap[code]
  if code and not isrepeat then
    self.keys[code]:onPress(isrepeat)
  end
end
-- Called when player releases any key.
-- @param(code : string) the code of the key based on keyboard layout
-- @param(scancode : string) the code of the key
function InputManager:onRelease(code, scancode)
  code = KeyMap[code]
  if code then
    self.keys[code]:onRelease()
  end
end

---------------------------------------------------------------------------------------------------
-- Mouse
---------------------------------------------------------------------------------------------------

-- Called when a mouse button is pressed.
-- @param(x : number) cursor's x coordinate
-- @param(y : number) cursor's y coordinate
-- @param(button : number) button type (1 to 3)
function InputManager:onMousePress(x, y, button)
  if not self.mouseEnabled then return end
  local code = KeyMap['mouse' .. button]
  if code then
    self.keys[code]:onPress()
  end
  self.mouse:onPress(button)
end
-- Called when a mouse button is released.
-- @param(x : number) cursor's x coordinate
-- @param(y : number) cursor's y coordinate
-- @param(button : number) button type (1 to 3)
function InputManager:onMouseRelease(x, y, button)
  if not self.mouseEnabled then return end
  local code = KeyMap['mouse' .. button]
  if code then
    self.keys[code]:onRelease()
  end
  self.mouse:onRelease(button)
end
-- Called when the cursor moves.
-- @param(x : number) cursor's x coordinate
-- @param(y : number) cursor's y coordinate
function InputManager:onMouseMove(x, y)
  if not self.mouseEnabled then return end
  self.mouse:onMove(x, y)
end

return InputManager