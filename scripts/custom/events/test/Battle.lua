--[[===============================================================================================

Battle Test
---------------------------------------------------------------------------------------------------

=================================================================================================]]

return function(script)

  script:startBattle { fieldID = 0, fade = 5, intro = true, gameOverCondition = 1, escapeEnabled = true}

  util.general.printBattleResult()

  if BattleManager:playerWon() then
    script:deleteChar { key = "self", permanent = true }
  end
  
end