
--[[===============================================================================================

TroopAI
---------------------------------------------------------------------------------------------------
The default AI for troops. Just executes all battlers' individual AIs, if they have one.

=================================================================================================]]

local TroopAI = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(troop : Troop) The troop with this AI.
-- @param(param : table) Custom arguments.
function TroopAI:init(troop, param)
  self.troop = troop
  self.param = param
end
-- @param(data : table) The info about the AI script (path and param).
-- @param(troop : Troop) The troop with the AI.
-- @ret(TroopAI)
function TroopAI:fromData(data, troop)
  local class = self
  if data.path ~= '' then
    class = require('custom/ai/troop/' .. data.path)
  end
  return class(troop, data.param)
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Manages the action for each member in order.
-- If a battler does not have an AI, it is ignored and does nothing.
function TroopAI:runTurn()
  local i, result = 1, nil
  while i <= #TurnManager.turnCharacters do
    TurnManager.characterIndex = i
    local char = TurnManager:currentCharacter()
    local AI = char.battler:getAI()
    if AI then
      result = AI:runTurn()
      if result.endTurn then
        break
      end
      if result.endCharacterTurn then
        i = i + 1
      end
    else
      i = i + 1
    end
  end
  return result
end

return TroopAI
