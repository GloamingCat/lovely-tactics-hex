--[[===============================================================================================

Wanderer
---------------------------------------------------------------------------------------------------
NPC that walks around while it is not blocking the player.

-- Arguments:
<pause>
<pauseVar>
<speed>

=================================================================================================]]

-- Alias
local rand = love.math.random

return function(script)
  local pause = tonumber(script.args.pause) or 60
  local pauseVar = tonumber(script.args.pauseVar) or 0
  
  while true do
    script.char:playIdleAnimation()
    if script.player.interacting or script.player.colliding or script.char.colliding then
      coroutine.yield()
    else
      script:wait(pause + rand(-pauseVar, pauseVar))
      local angle = (rand(8) - 1) * 45
      script.char:tryAngleMovement(angle)
    end
  end
  
end