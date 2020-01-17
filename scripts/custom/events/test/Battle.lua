
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
  script:startBattle { fieldID = script.args.fieldID or 0, fade = 60, intro = true, 
    gameOverCondition = 1, escapeEnabled = true }
  
  if BattleManager:playerWon() then
    print 'You won!'
    script:deleteChar { key = "self", fade = 60, permanent = true }
  elseif BattleManager:enemyWon() then
    print 'You lost...'
  elseif BattleManager:drawed() then
    print 'Draw.'
  elseif BattleManager:playerEscaped() then
    print 'You escaped!'
  elseif BattleManager:enemyEscaped() then
    print 'The enemy escaped...'
  end

end
