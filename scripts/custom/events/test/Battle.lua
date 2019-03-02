--[[===============================================================================================

Battle Test
---------------------------------------------------------------------------------------------------
Starts a battle when this collides with player.

=================================================================================================]]

return function(script)

  if script.collider ~= script.player and script.collided ~= script.player then
    -- Collided with something else
    return
  end
  
  if script.player:isBusy() or script.player.blocks > 1 then
    -- Player is moving, on battle, or waiting for GUI input
    return
  end
  
  script.player:playIdleAnimation()
  script:startBattle { fieldID = 0, fade = 5, intro = true, 
    gameOverCondition = 1, escapeEnabled = true }
  
  util.general.printBattleResult()
  if BattleManager:playerWon() then
    script:deleteChar { key = "self", permanent = true }
  end
  
end