
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
    FieldManager.renderer:fadein(0)
    clear(script)
    return
    
  elseif mode == 2 then
    
    -----------------------------------------------------------------------------------------------
    -- Test boss scene
    -----------------------------------------------------------------------------------------------

    FieldManager.renderer:fadein(0)
    script:moveToField { fieldID = 6, x = 7, y = 3, h = 1, direction = 135 }
    clear(script)
    return
    
  end
  
  -------------------------------------------------------------------------------------------------
  -- Skip intro
  -------------------------------------------------------------------------------------------------
  
  if InputManager.keys['cancel']:isPressing() then
    FieldManager.renderer:fadein(0)
    clear(script)
    return
  end
  
  -------------------------------------------------------------------------------------------------
  -- Intro scenes
  -------------------------------------------------------------------------------------------------
  
  script:forkFromScript { name = 'events/town/Intro', wait = true } : waitForEnd()
  script:forkFromScript { name = 'events/town/Battle', wait = true } : waitForEnd()

  -------------------------------------------------------------------------------------------------
  -- Finish
  -------------------------------------------------------------------------------------------------

  Fiber:wait(30)
  clear(script)
  FieldManager.renderer:fadein(180, true)
  
end
