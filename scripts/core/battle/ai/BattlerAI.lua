
--[[===============================================================================================

BattlerAI
---------------------------------------------------------------------------------------------------
Implements basic functions to be used in AI classes.

=================================================================================================]]

-- Imports
local AIRule = require('core/battle/ai/AIRule')
local BattleCursor = require('core/battle/BattleCursor')

local BattlerAI = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(commands : table) Array of event sheet commands.
-- @param(battler : Battler) The battler with this AI.
-- @param(param : string) Any custom arguments.
function BattlerAI:init(battler, commands, param)
  self.battler = battler
  self.commands = commands
  self.param = param
end
-- Creates an AI script from the given rule data.
-- @param(data : table) Rule data with path, param and condition fields.
-- @return(BattlerAI)
function BattlerAI:fromData(data, battler)
  local class = self
  if data.path and data.path ~= '' then
    class = require('custom/ai/battler/' .. data.path)
  end
  return class(battler, data.commands, data.param)
end
-- @ret(string) String identifier.
function BattlerAI:__tostring()
  return 'AI: ' .. self.battler.key
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Executes next action of the current character, when it's the character's turn.
-- By default, just skips turn, with no time loss.
-- @ret(number) The action result table.
function BattlerAI:runTurn()
  local char = TurnManager:currentCharacter()
  self:showCursor(char)
  TurnManager:characterTurnStart()
  local event = { AI = self,
    self = char,
    origin = char,
    user = self.battler }
  local fiber = FieldManager.fiberList:forkFromScript(self.commands, event)
  fiber:waitForEnd()
  local result = self.result or AIRule(self.battler):execute()
  self.result = nil
  TurnManager:characterTurnEnd(result)
  return result
end
-- Shows the cursor over the current character.
function BattlerAI:showCursor(char)
  FieldManager.renderer:moveToObject(char, nil, true)
  local cursor = BattleCursor()
  cursor:setTile(char:getTile())
  cursor:show()
  local t = 0.5
  while t > 0 do
    t = t - love.timer.getDelta()
    cursor:update()
    coroutine.yield()
  end
  cursor:destroy()
end

return BattlerAI
