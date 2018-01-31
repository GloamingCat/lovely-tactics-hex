
--[[===============================================================================================

FocusPause
---------------------------------------------------------------------------------------------------
Pauses game when window loses focus.

=================================================================================================]]

-- Parameters
local pauseAudio = args.pauseAudio == 'true'

local love_focus = love.focus
function love.focus(f)
  love_focus(f)
  GameManager:setPaused(not f, pauseAudio, true)
end