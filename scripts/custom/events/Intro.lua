
--[[===============================================================================================

Intro
---------------------------------------------------------------------------------------------------
Intro scene. Chita tells the background story.

=================================================================================================]]

-- Auxiliary function to clear intro scene.
local function clear(script)
  script:deleteChar { key = 'Chita', permanent = true }
  script:deleteChar { key = 'Heron', permanent = true }
  script:deleteChar { key = 'Jelly', permanent = true }
  script:turnCharDir { key = "player", angle = 270 }
  AudioManager:playBGM (Sounds.townTheme)
  FieldManager.currentField.loadScript = { name = '' }
end

-- For debug. 
-- mode = 0 is default intro scene.
local mode = 0

return function(script)
  
  if mode == 1 then
    AudioManager.battleTheme = nil
    script:startBattle { fieldID = 12, fade = 5, intro = true, 
      gameOverCondition = 1, escapeEnabled = true }
    AudioManager.battleTheme = Sounds.battleTheme
    clear(script)
    return
  end
  
  if InputManager.keys['cancel']:isPressing() then
    -- Skip intro
    clear(script)
    return
  end
  
  script:fadeout {}
  
  FieldManager.renderer.images.BG1:setVisible(true)
  
  Fiber:wait(30)
  
  -------------------------------------------------------------------------------------------------
  -- First part of the storytelling.
  -------------------------------------------------------------------------------------------------
  
  script:openDialogueWindow { id = 1, x = 0, y = 0,
    width = ScreenManager.width * 3 / 4, 
    height = ScreenManager.height / 3 
  }

  script:showDialogue { id = 1, character = '', message = 
    Vocab.dialogues.TheWorldOf
  }
  
  script:showDialogue { id = 1, message = 
    Vocab.dialogues.OurPeople
  }

  script:showDialogue { id = 1, message = 
    Vocab.dialogues.HoweverAfterMany
  }
  
  script:closeDialogueWindow { id = 1 }

  script:fadein { time = 300, wait = true }
  Fiber:wait(60)

  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3 
  }

  script:showDialogue { id = 1, character = "Chita", portrait = "Serious", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.BecauseWhen
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.Jelly
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Happy", message = 
    Vocab.dialogues.YayJelly
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.NoYay
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Wonder", message = 
    Vocab.dialogues.HowCanFood
  }
  
  AudioManager:playSFX { name = "sfx/CGEffex/slap.ogg", pitch = 100, volume = 100 }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "FacePalm", message = 
    "..."
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.TheyAreNotFood
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Cry", message = 
    Vocab.dialogues.AwnItsBecause
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.Focus
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Focus", message = 
    Vocab.dialogues.OkOk
  }
  
  script:closeDialogueWindow { id = 1 }
  
  script:fadeout { time = 150, wait = true }
  Fiber:wait(60)
  
  -------------------------------------------------------------------------------------------------
  -- Second part of the storytelling.
  -------------------------------------------------------------------------------------------------
  
  script:openDialogueWindow { id = 1, x = 0, y = 0,
    width = ScreenManager.width * 3 / 4, 
    height = ScreenManager.height / 3 
  }
  
  script:showDialogue { id = 1, character = '', message = 
    "Ahem."
  }
  
  script:showDialogue { id = 1, message = 
    Vocab.dialogues.FortunatelyTheWitches
  }
  
  script:showDialogue { id = 1, message = 
    Vocab.dialogues.OrAtLeast
  }
  
  script:showDialogue { id = 1, message = 
    Vocab.dialogues.OneDay
  }
  
  script:closeDialogueWindow { id = 1 }

  script:fadein { time = 150, wait = true }
  Fiber:wait(30)

  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3 
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Worry", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.OhNo
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Serious", message = 
    Vocab.dialogues.WeTried
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.YouAreOurLastHope
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Worry", message = 
    Vocab.dialogues.ButBut
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.YouAreNotAlone
  }
  
  script:closeDialogueWindow { id = 1 }
    
  -------------------------------------------------------------------------------------------------
  -- Heron shows up.
  -------------------------------------------------------------------------------------------------
  
  AudioManager:playSFX { name = "sfx/Kenney/door.ogg" }
  script:fadeout { time = 90, wait = true }
  AudioManager:playBGM(Sounds.battleTheme)
  FieldManager.renderer.images.BG1:setVisible(false)
  FieldManager.renderer.images.BG2:setVisible(true)
  script:fadein { time = 60, wait = true }
  
  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3 
  }
  
  script:showDialogue { id = 1, character = "Heron", portrait = "Scared", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.TumTumHelp
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.WhatHappened
  }
  
  script:showDialogue { id = 1, character = "Heron", portrait = "Scared", message = 
    Vocab.dialogues.AnEvilJelly
  }
  
  script:closeDialogueWindow { id = 1 }
  
  -------------------------------------------------------------------------------------------------
  -- Move outside.
  -------------------------------------------------------------------------------------------------
  
  script:fadeout { time = 150, wait = true }
  FieldManager.renderer.images.BG2:setVisible(false)
  script:wait(60)
  script:fadein { time = 180, wait = true }
  
  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3 
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Cry", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.WhatDoIDo
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.CalmDown
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Focus", message = 
    Vocab.dialogues.OkIllDoIt
  }
  
  script:closeDialogueWindow { id = 1 }
  
  AudioManager.battleTheme = nil
  script:startBattle { fieldID = 11, fade = 5, intro = true, 
    gameOverCondition = 1, escapeEnabled = false }
  AudioManager.battleTheme = Sounds.battleTheme
  
  -------------------------------------------------------------------------------------------------
  -- After battle.
  -------------------------------------------------------------------------------------------------
  
  script:deleteChar { key = 'Jelly', fade = 90, permanent = true, wait = true }
  
  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3
  }
  
  script:showDialogue { id = 1, character = "Heron", portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.ThankYouAmazing
  }
  
  script:closeDialogueWindow { id = 1 }
  
  AudioManager:playBGM (Sounds.happyTheme)
  
  Fiber:wait(30)
  local angle = 45
  while angle < 225 do
    angle = angle + 45
    script:turnCharDir { key = "player", angle = angle }
    Fiber:wait(4)
  end
  Fiber:wait(30)
  
  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Blush", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.ThatWasNothing
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Serious", message = 
    Vocab.dialogues.WellDone
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Wonder", message = 
    Vocab.dialogues.IThink
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Determined", message = 
    Vocab.dialogues.ThoseJellies
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Pleased", message = 
    Vocab.dialogues.WayBetter
  }
  
  script:closeDialogueWindow { id = 1 }

  -------------------------------------------------------------------------------------------------
  -- Finish.
  -------------------------------------------------------------------------------------------------

  script:fadeout { time = 180, wait = true }
  script:deleteChar { key = 'Chita', permanent = true }
  script:deleteChar { key = 'Heron', permanent = true }
  script:turnCharDir { key = "player", angle = 270 }
  Fiber:wait(30)
  AudioManager:playBGM (Sounds.townTheme)
  script:fadein { time = 180, wait = true }
  
  FieldManager.currentField.loadScript = { name = '' }
  
end
