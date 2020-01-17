
--[[===============================================================================================

Intro
---------------------------------------------------------------------------------------------------
First scene after title screen.

=================================================================================================]]

-- For debug. 
-- mode = 0 is default intro scene.
local mode = 0

-- Auxiliary function to clear intro scene.
local function clear(script)
  script:deleteChar { key = 'Chita', permanent = true, optional = true }
  script:deleteChar { key = 'Heron', permanent = true, optional = true }
  script:deleteChar { key = 'Jelly', permanent = true, optional = true }
  script:turnCharDir { key = "player", angle = 270 }
  AudioManager:playBGM (Sounds.townTheme)
  FieldManager.currentField.loadScript = { name = '' }
end

return function(script)
  
  if mode == 1 then
    
    -----------------------------------------------------------------------------------------------
    -- Test battle
    -----------------------------------------------------------------------------------------------
  
    script:addMember { key = 'BlimBlim', x = 0, y = 0 }
    --AudioManager.battleTheme = nil
    AudioManager:setBGMVolume(1)
    script:startBattle { fieldID = 12, fade = 60, intro = true, 
      gameOverCondition = 1, escapeEnabled = true }
    --AudioManager.battleTheme = Sounds.battleTheme
    clear(script)
    return
    
  elseif mode == 2 then
    
    -----------------------------------------------------------------------------------------------
    -- Test boss scene
    -----------------------------------------------------------------------------------------------

    script:moveToField { fieldID = 6, x = 7, y = 3, h = 1, direction = 135 }
    clear(script)
    return
    
  end
  
  -------------------------------------------------------------------------------------------------
  -- Skip intro
  -------------------------------------------------------------------------------------------------
  
  if InputManager.keys['cancel']:isPressing() then
    clear(script)
    return
  end
  
  -------------------------------------------------------------------------------------------------
  -- Intro scenes
  -------------------------------------------------------------------------------------------------
  
  FieldManager.renderer:fadeout(0)
  
  script:forkFromScript { name = 'events/town/Intro', wait = true }
  script:forkFromScript { name = 'events/town/Battle', wait = true }

  -------------------------------------------------------------------------------------------------
  -- Finish
  -------------------------------------------------------------------------------------------------

  Fiber:wait(30)
  clear(script)
  FieldManager.renderer:fadein(180, true)
  
end
