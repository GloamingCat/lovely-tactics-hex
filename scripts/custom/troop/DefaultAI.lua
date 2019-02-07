
--[[===============================================================================================

DefaultAI
---------------------------------------------------------------------------------------------------
Default troop AI. Manages the action for each member in order.
If a battler does not have an AI, it is ignored and does nothing.

=================================================================================================]]

return function (troop)
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
