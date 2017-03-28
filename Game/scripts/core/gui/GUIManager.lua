
--[[===========================================================================

GUIManager
-------------------------------------------------------------------------------
This class manages all GUI objects.

=============================================================================]]

-- Imports
local Stack = require('core/algorithm/Stack')
local Renderer = require('core/graphics/Renderer')
local CallbackTree = require('core/callback/CallbackTree')

local GUIManager = require('core/class'):new()

-------------------------------------------------------------------------------
-- General
-------------------------------------------------------------------------------

function GUIManager:init()
  self.renderer = Renderer(200, -100, 100)
  self.stack = Stack()
  self.paused = false
  self.callbackTree = CallbackTree()
end

-- Calls all the update functions
function GUIManager:update()
  if self.current then
    self.current:update()
  end
  self.callbackTree:update()
end

-------------------------------------------------------------------------------
-- GUI calls
-------------------------------------------------------------------------------

-- Tells if there's any GUI waiting for player's input.
function GUIManager:isWaitingInput()
  return self.current and self.current.activeWindow ~= nil
end

function GUIManager:loadGUI(path, block, ...)
  
end

-- [COROUTINE] Shows GUI and waits until returns a result.
-- @param(path : string) the GUI path from custom/gui folder.
-- @param(block : boolean) tells if it's supposed to block FieldManager updates
function GUIManager:showGUIForResult(path, block, ...)
  local arg = {...}
  if block then
    local result = nil
    self.callbackTree:fork(function()
        FieldManager.paused = true
        result = self:showGUIForResult(path, false, unpack(arg))
        FieldManager.paused = false
      end)
    coroutine.yield()
    return result
  else
    local gui = self:showGUI(path, unpack(arg))
    local result = gui:waitForResult()
    self:returnGUI()
    return result
  end
end

-- [COROUTINE] Shows GUI and adds to the stack.
-- @param(path : string) the GUI path from custom/gui folder.
function GUIManager:showGUI(path, ...)
  if self.current then
    self.stack:push(self.current)
    --self.current:hide()
  end
  local newGUI = require('custom/gui/' .. path)(...)
  self.current = newGUI
  newGUI:show()
  return newGUI
end

-- [COROUTINE] Closes current GUI and returns to the previous.
function GUIManager:returnGUI()
  local lastGUI = self.current
  lastGUI:hide()
  lastGUI:destroy()
  if not self.stack:isEmpty() then
    self.current = self.stack:pop()
    --self.current:show()
  else
    self.current = nil
  end
end

return GUIManager
