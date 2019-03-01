--[[===============================================================================================

Battle Test
---------------------------------------------------------------------------------------------------
Starts a battle when this collides with player.

=================================================================================================]]

return function(script)

  if script.collider ~= script.player and script.collided ~= script.player then
    return
  end
  
  script:startBattle { fieldID = 0, fade = 5, intro = true, 
    gameOverCondition = 1, escapeEnabled = true}

  util.general.printBattleResult()

  if BattleManager:playerWon() then
    script:deleteChar { key = "self", permanent = true }
  end
  
end