
--[[===============================================================================================

GUI
---------------------------------------------------------------------------------------------------
Manages a set of GUI elements (generally, a set of windows).

=================================================================================================]]

-- Imports
local List = require('core/base/datastruct/List')

-- Alias
local yield = coroutine.yield

local GUI = class()

---------------------------------------------------------------------------------------------------
-- Initialization 
---------------------------------------------------------------------------------------------------

-- Constructor.
function GUI:init()
  self.windowList = List()
  self:createWindows()
  self.open = false
  self.closed = true
end
-- Creates the GUI's windows and sets the first active window.
function GUI:createWindows()
 -- Abstract.
end
-- @ret(number) Distance between windows
function GUI:windowMargin()
  return 4
end
  
---------------------------------------------------------------------------------------------------
-- General 
---------------------------------------------------------------------------------------------------

-- Updates all windows.
function GUI:update()
  for window in self.windowList:iterator() do
    window:update()
  end
end
-- Destroys all windows.
function GUI:destroy()
  for window in self.windowList:iterator() do
    window:destroy()
  end
  collectgarbage('collect')
end
-- String representation.
function GUI:__tostring()
  local name = self.name or 'Nameless'
  return 'GUI: ' .. name
end

---------------------------------------------------------------------------------------------------
-- Active Window
---------------------------------------------------------------------------------------------------

-- Changes GUI's active window.
function GUI:setActiveWindow(window)
  if self.activeWindow then
    self.activeWindow:setActive(false)
  end
  self.activeWindow = window
  if window then
    window:setActive(true)
  end
end
-- [COROUTINE] Waits until GUI closes and returns a result.
-- @ret The result of GUI (will never be nil).
function GUI:waitForResult()
  if self.activeWindow then
    self.activeWindow:checkInput()
  end
  while not self.activeWindow or self.activeWindow.result == nil do
    yield()
    if self.activeWindow then
      self.activeWindow:checkInput()
    end
  end
  return self.activeWindow.result
end
-- [COROUTINE] Waits until window closes and returns a result.
-- @param(window : Window) The new active window.
-- @ret The result of window (will never be nil).
function GUI:showWindowForResult(window)
  local previous = self.activeWindow
  window:show()
  window:activate()
  local result = self:waitForResult()
  window.result = nil
  window:hide()
  previous:activate()
  return result
end

---------------------------------------------------------------------------------------------------
-- Coroutine calls
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Shows all windows.
function GUI:show()
  if self.open then
    return
  end
  self.closed = false
  for window in self.windowList:iterator() do
    if window.lastOpen then
      GUIManager.fiberList:fork(function()
        window:show()
      end)
    end
  end
  local done
  repeat
    done = true
    for window in self.windowList:iterator() do
      if window.lastOpen and window.scaleY < 1 then
        done = false
      end
    end
    yield()
  until done
  self.open = true
end
-- [COROUTINE] Hides all windows.
function GUI:hide()
  if not self.closed then
    self.open = false
    for window in self.windowList:iterator() do
      GUIManager.fiberList:fork(function()
        window:hide(true)
      end)
    end
    local done
    repeat
      done = true
      for window in self.windowList:iterator() do
        if window.scaleY > 0 then
          done = false
        end
      end
      yield()
    until done
    self.closed = true
  end
end

return GUI
