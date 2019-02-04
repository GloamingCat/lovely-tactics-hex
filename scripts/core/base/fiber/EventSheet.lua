
--[[===============================================================================================

EventSheet
---------------------------------------------------------------------------------------------------
A fiber that processes a list of sequential commands.

=================================================================================================]]

-- Imports
local Fiber = require('core/base/fiber/Fiber')

-- Alias
local insert = table.insert
local readFile = love.filesystem.read

-- Cache
local ScriptCache = {}

local EventSheet = class(Fiber)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(root : FiberList)
-- @param(state : table) state data from save (ignored if the event is new)
function EventSheet:init(root, data, char)
  self.name = data.name
  self.vars = data.vars or 0
  self.code = data.code
  if root then
    root.eventSheets:add(self)
  end
  local code = data.code or readFile('scripts/custom/' .. data.name)
  assert(code, "Could not load event sheet file: " .. (data.name or 'nil'))
  if ScriptCache[code] then
    self.commands = ScriptCache[code]
  else
    self.commands = self:preprocess(code)
    ScriptCache[code] = self.commands
  end
  self.args = Database:loadTags(data.tags)
  self.player = FieldManager.player
  self.field = FieldManager.currentField
  if char or data.char then
    self.char = char or data.char and FieldManager:search(data.char)
  end
  Fiber.init(self, root, nil)
end
-- Persistent state to save.
-- @ret(table) Table with command list, current command index and local variables.
function EventSheet:getState()
  return {
    name = self.name,
    code = self.code,
    vars = self.vars,
    char = self.char and self.char.key,
    tags = self.args:toList() }
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Creates a function from the given commands.
-- @param(commands : string) Script commands.
-- @ret(function) Execution function.
function EventSheet:preprocess(commands)
  local header = "return function(script)\n"
  local script = header .. commands .. " end"
  return loadstring(script)()
end
-- Runs the script commands.
function EventSheet:execute()
  local player = FieldManager.player
  if self.block then
    player.blocks = player.blocks + 1
  end
  self:commands()
  if self.gui then
    GUIManager:returnGUI()
    self.gui = nil
  end
  if self.block then
    player.blocks = player.blocks - 1
  end
end
-- Interrupts the current executing sheet.
function EventSheet:interrupt(args)
  _G.Fiber:interrupt()
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