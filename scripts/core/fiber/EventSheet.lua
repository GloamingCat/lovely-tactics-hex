
--[[===============================================================================================

EventSheet
---------------------------------------------------------------------------------------------------
A fiber that processes a list of sequential commands.

=================================================================================================]]

-- Imports
local Fiber = require('core/fiber/Fiber')

local EventSheet = class(Fiber)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(root : FiberList)
-- @param(state : table) state data from save (ignored if the event is new)
function EventSheet:init(root, script, char)
  if script.func then
    self.commands = script.func
  else
    local func = require('custom/' .. script.name)
    assert(func, "Could not load event sheet file: " .. (script.name or 'nil'))
    self.commands = func
  end
  self.block = script.block
  self.args = Database:loadTags(script.tags)
  self.player = FieldManager.player
  self.field = FieldManager.currentField
  self.char = char
  Fiber.init(self, root, nil)
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Runs the script commands.
function EventSheet:execute()
  local player = FieldManager.player
  if player and self.block then
    player.blocks = player.blocks + 1
  end
  self:commands()
  if self.gui then
    GUIManager:returnGUI()
    self.gui = nil
  end
  if player and self.block then
    player.blocks = player.blocks - 1
  end
end

---------------------------------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------------------------------

-- Searches for the character with the given key.
function EventSheet:findCharacter(key)
  if key == 'self' then
    return self.char
  end
  local char = FieldManager:search(key)
  assert(char, 'Character not found:', key or 'nil key')
  return char
end
-- Load other commands.
local files = {'General', 'GUI', 'Character', 'Screen', 'Sound'}
for i = 1, #files do
  local commands = require('core/event/' .. files[i] .. 'Events')
  for k, v in pairs(commands) do
    EventSheet[k] = v
  end
end

return EventSheet