
--[[===============================================================================================

EventSheet
---------------------------------------------------------------------------------------------------
A fiber that processes a list of sequential commands.

=================================================================================================]]

-- Imports
local Fiber = require('core/fiber/Fiber')

-- Alias
local insert = table.insert

local EventSheet = class(Fiber)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(root : FiberList)
-- @param(commands : table) array of commands from json file (ignored if loaded from save)
-- @param(state : table) state data from save (ignored if the event is new)
function EventSheet:init(root, commands, event, state)
  if state then
    self.index = state.commands
    self.commands = state.commands
    self.vars = state.vars
  else
    self.index = 0
    self.commands = self:preprocess(commands)
    self.vars = {}
  end
  self:addLabels()
  if root then
    root.eventSheets:add(self)
  end
  event.player = FieldManager.player
  event.field = FieldManager.currentField
  Fiber.init(self, root, nil, event)
end

function EventSheet:getState()
  return {
    index = self.index,
    commands = self.commands,
    vars = self.vars }
end

---------------------------------------------------------------------------------------------------
-- Preprocess
---------------------------------------------------------------------------------------------------

-- @param(raw : table) array of raw commands (includes conditionals)
-- @param(depth : number) indentation (0 by default)
-- @ret(table) array of new commands (does not include conditionals)
function EventSheet:preprocess(raw, depth)
  depth = depth or 0
  local commands = {}
  local n = 0
  for i = 1, #raw do
    n = n + 1
    local name = raw[i].name
    if name == 'condition' then
      n = self:preprocessCondition(raw[i], commands, n, depth)
    elseif name == 'eventScript' then
      n = self:preprocessEventScript(raw[i], commands, n, depth)
    else
      commands[n] = raw[i]
    end
  end
  return commands
end
-- @param(command : table) event script command
-- @param(commands : table) array of commands
-- @param(n : number) the total number of commands
-- @param(depth : number) the indentation depth
-- @ret(number) new number of commands
function EventSheet:preprocessEventScript(command, commands, n, depth)
  local script = Database.scripts[command.param]
  local scriptCommands = self:preprocess(script.commands, depth + 1)
  for i = 1, #scriptCommands do
    commands[i + n - 1] = scriptCommands[i]
  end
  return n + #scriptCommands
end
-- @param(command : table) condition command
-- @param(commands : table) array of commands
-- @param(n : number) the total number of commands
-- @param(depth : number) the indentation depth
-- @ret(number) new number of commands
function EventSheet:preprocessCondition(command, commands, n, depth)
  local _if = self:preprocess(command.param['if'], depth + 1)
  local _else = self:preprocess(command.param['else'], depth + 1)
  local exp = 'not (' .. command.param.expression .. ')'
  -- Labels
  local endif = 'endif' .. depth .. '.' .. (n + #_if)
  local endelse = 'endelse' .. depth .. '.' .. (n + #_if + #_else + 1)
  -- Jumps to endif if condition is false
  commands[n] = {
    name = 'jump',
    param = { expression = exp, label = endif } }
  -- If commands
  for j = 1, #_if do
    commands[n + j] = _if[j]
  end
  n = n + #_if + 1
  -- Jumps to endelse at the end of if commands
  commands[n] = {
    name = 'jump',
    param = { label = endelse } }
  n = n + 1
  -- Endif label
  commands[n] = {
    name = 'label',
    param = endif }
  -- Else commands
  for j = 1, #_else do
    commands[n + j] = _else[j]
  end
  n = n + #_else + 1
  -- Endelse label
  commands[n] = {
    name = 'label',
    param = endelse }
  return n
end

function EventSheet:addLabels()
  self.labels = {}
  for i = 1, #self.commands do
    local command = self.commands[i]
    if command.name == 'label' then
      self.labels[command.param] = i + 1
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Process
---------------------------------------------------------------------------------------------------

function EventSheet:execute(event)
  local player = FieldManager.player
  if event.block then
    player.blocks = player.blocks + 1
  end
  while self.index < #self.commands do
    self.index = self.index + 1
    local command = self.commands[self.index]
    if command.name == 'jump' then
      assert(self.labels[command.param.label], 'Label not defined: ' .. command.param.label)
      local expr = command.param.expression
      local value = expr == nil or self:decodeExpression(event, expr)
      if value then
        self.index = self.labels[command.param.label]
      end
    elseif command.name == 'fork' then
      EventSheet(self.root, command.param)
    elseif command.name == 'script' then
      util.executeScript(command.param)
    elseif command.name == 'wait' then
      _G.Fiber:wait(command.param)
    elseif command.name ~= 'label' then
      assert(util.event[command.name], 'Command does not exist: ' .. command.name)
      util.event[command.name](self, event, command.param)
    end
  end
  if self.gui then
    GUIManager:returnGUI()
    self.gui = nil
  end
  if event.block then
    player.blocks = player.blocks - 1
  end
end

function EventSheet:decodeExpression(event, expression)
  return loadformula(expression, 'sheet, event')(self, event)
end

return EventSheet