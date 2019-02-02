
--[[===============================================================================================

FiberList
---------------------------------------------------------------------------------------------------
A List of Fibers. Must be updated every frame.

=================================================================================================]]

-- Imports
local EventSheet = require('core/base/fiber/EventSheet')
local Fiber = require('core/base/fiber/Fiber')
local List = require('core/base/datastruct/List')

local FiberList = class(List)

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(state : table) Persistent state if loaded from save (optional).
function FiberList:init(state, char)
  List.init(self)
  self.char = char
  self.eventSheets = List()
  if state then
    for i = 1, #state do
      local sheet = EventSheet(self, nil, state[i])
    end
  end
end
-- Updates all Fibers.
function FiberList:update()
  for i = 1, self.size do
    self[i]:update()
  end
  self:conditionalRemove(self.isFinished)
end
-- Function that resumes a Fiber.
-- @param(fiber : Fiber) Fiber to resume.
-- @ret(boolean) True if Fiber ended, false otherwise.
function FiberList.isFinished(fiber)
  return fiber.coroutine == nil
end

---------------------------------------------------------------------------------------------------
-- Fork
---------------------------------------------------------------------------------------------------

-- Creates new Fiber from function.
-- @param(func : function) The function of the Fiber.
-- @param(...) Any arguments to the function.
-- @ret(Fiber) The newly created Fiber.
function FiberList:fork(func, ...)
  return Fiber(self, func, ...)
end
-- Creates new Fiber from a script table.
-- @ret(EventSheet) The newly created Fiber.
function FiberList:forkFromScript(script, ...)
  return EventSheet(self, script, ...)
end

---------------------------------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------------------------------

-- Fiber's state. It considers only its event sheets.
-- @ret(table) Array with the states of each event sheet.
function FiberList:getState()
  local state = {}
  for i = 1, #self.eventSheets do
    state[i] = self.eventSheets[i]:getState()
  end
  return state
end

return FiberList
