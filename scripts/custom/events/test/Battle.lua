
--[[===============================================================================================

Battle Test
---------------------------------------------------------------------------------------------------
Starts a battle when this collides with player.

=================================================================================================]]

return function(script)

  coroutine.yield()

  if script.char.cooldown and script.char.cooldown > 0 then
    -- After-battle cooldown (escape or lose)
    script.char.cooldown = script.char.cooldown - GameManager:frameTime() * 60
    --return
  end

  if script.collider ~= script.player and script.collided ~= script.player then
    -- Collided with something else
    return
  end
  
  if script.player:isBusy() or script.player.blocks > 1 then
    -- Player is moving, on battle, or waiting for GUI input
    return
  end
  
  script.player:playIdleAnimation()
  script:startBattle { 
    fieldID = tonumber(script.args.fieldID) or 0, 
    fade = 60, 
    intro = true, 
    gameOverCondition = script.args.loseEnabled == 'true' and 0 or 1, 
    escapeEnabled = true 
  }
  
  if BattleManager:playerWon() then
    print 'You won!'
    script:deleteChar { key = "self", fade = 60, permanent = true }
  elseif BattleManager:enemyWon() then
    print 'You lost...'
    script.char.cooldown = 120
  elseif BattleManager:drawed() then
    print 'Draw.'
    script.char.cooldown = 120
  elseif BattleManager:playerEscaped() then
    print 'You escaped!'
    script.char.cooldown = 120
  elseif BattleManager:enemyEscaped() then
    print 'The enemy escaped...'
    script:deleteChar { key = "self", fade = 60, permanent = true }
  end

end
