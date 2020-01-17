
--[[===============================================================================================

Town - Battle
---------------------------------------------------------------------------------------------------
First battle. Jelly invades town.

=================================================================================================]]

return function(script)

  FieldManager.renderer:fadein(180, true)
  
  script:showDialogue { id = 1, character = "player", portrait = "Cry", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.intro.WhatDoIDo
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.intro.CalmDown
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Focus", message = 
    Vocab.dialogues.intro.OkIllDoIt
  }
  
  script:closeDialogueWindow { id = 1 }
  
  AudioManager.battleTheme = nil
  script:startBattle { fieldID = 11, fade = 60, intro = true, 
    gameOverCondition = 1, escapeEnabled = false }
  AudioManager.battleTheme = Sounds.battleTheme
  
  -------------------------------------------------------------------------------------------------
  -- After battle.
  -------------------------------------------------------------------------------------------------
  
  script:deleteChar { key = 'Jelly', fade = 90, permanent = true, wait = true }
  
  script:showDialogue { id = 1, character = "Heron", portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.intro.ThankYouAmazing
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

  script:showDialogue { id = 1, character = "player", portrait = "Blush", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.intro.ThatWasNothing
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Serious", message = 
    Vocab.dialogues.intro.WellDone
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Wonder", message = 
    Vocab.dialogues.intro.IThink
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Determined", message = 
    Vocab.dialogues.intro.ThoseJellies
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Pleased", message = 
    Vocab.dialogues.intro.WayBetter
  }
  
  script:closeDialogueWindow { id = 1 }
  
  FieldManager.renderer:fadeout(180, true)
  
end
