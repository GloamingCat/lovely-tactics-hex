--[[===============================================================================================

Wanderer
---------------------------------------------------------------------------------------------------
NPC that walks around while it is not blocking the player.

-- Arguments:
<pause> Pause in frames between each step.
<pauseVar> Variation of the pause in frames.

=================================================================================================]]

-- Alias
local rand = love.math.random

return function(script)
  local pause = tonumber(script.args.pause) or 60
  local pauseVar = tonumber(script.args.pauseVar) or 0
  
  while true do
    script.char:playIdleAnimation()
    if script.char.colliding then
      coroutine.yield()
    else
      script:wait(pause + rand(-pauseVar, pauseVar))
      local dir = 
      script.char:tryTileMovement(angle)
    end
  end
  
end