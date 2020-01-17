
--[[===============================================================================================

Town - Intro
---------------------------------------------------------------------------------------------------
Intro scene. Chita tells the background story.

=================================================================================================]]

return function(script)

  FieldManager.renderer.images.BG1:setVisible(true)
  Fiber:wait(30)
  
  -------------------------------------------------------------------------------------------------
  -- First part of the storytelling.
  -------------------------------------------------------------------------------------------------

  script:showDialogue { id = 3, character = '', message = 
    Vocab.dialogues.intro.TheWorldOf
  }
  
  script:showDialogue { id = 3, message = 
    Vocab.dialogues.intro.OurPeople
  }

  script:showDialogue { id = 3, message = 
    Vocab.dialogues.intro.HoweverAfterMany
  }
  
  script:closeDialogueWindow { id = 3 }

  FieldManager.renderer:fadein(300, true)
  Fiber:wait(60)

  script:showDialogue { id = 1, character = "Chita", portrait = "Serious", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.intro.BecauseWhen
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.intro.Jelly
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Happy", message = 
    Vocab.dialogues.intro.YayJelly
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.intro.NoYay
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Wonder", message = 
    Vocab.dialogues.intro.HowCanFood
  }
  
  AudioManager:playSFX { name = "sfx/CGEffex/slap.ogg", pitch = 100, volume = 100 }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "FacePalm", message = 
    "..."
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.intro.TheyAreNotFood
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Cry", message = 
    Vocab.dialogues.intro.AwnItsBecause
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.intro.Focus
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Focus", message = 
    Vocab.dialogues.intro.OkOk
  }
  
  script:closeDialogueWindow { id = 1 }
  
  FieldManager.renderer:fadeout(150, true)
  Fiber:wait(60)
  
  -------------------------------------------------------------------------------------------------
  -- Second part of the storytelling.
  -------------------------------------------------------------------------------------------------
  
  script:showDialogue { id = 3, character = '', message = 
    "Ahem."
  }
  
  script:showDialogue { id = 3, message = 
    Vocab.dialogues.intro.FortunatelyTheWitches
  }
  
  script:showDialogue { id = 3, message = 
    Vocab.dialogues.intro.OrAtLeast
  }
  
  script:showDialogue { id = 3, message = 
    Vocab.dialogues.intro.OneDay
  }
  
  script:closeDialogueWindow { id = 3 }

  FieldManager.renderer:fadein(150, true)
  Fiber:wait(30)
  
  script:showDialogue { id = 1, character = "player", portrait = "Worry", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.intro.OhNo
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Serious", message = 
    Vocab.dialogues.intro.WeTried
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.intro.YouAreOurLastHope
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Worry", message = 
    Vocab.dialogues.intro.ButBut
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.intro.YouAreNotAlone
  }
  
  script:closeDialogueWindow { id = 1 }
    
  -------------------------------------------------------------------------------------------------
  -- Heron shows up.
  -------------------------------------------------------------------------------------------------
  
  AudioManager:playSFX { name = "sfx/Kenney/door.ogg" }
  FieldManager.renderer:fadeout(90, true)
  AudioManager:playBGM(Sounds.battleTheme)
  FieldManager.renderer.images.BG1:setVisible(false)
  FieldManager.renderer.images.BG2:setVisible(true)
  FieldManager.renderer:fadein(60, true)
  
  script:showDialogue { id = 1, character = "Heron", portrait = "Scared", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.intro.TumTumHelp
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    Vocab.dialogues.intro.WhatHappened
  }
  
  script:showDialogue { id = 1, character = "Heron", portrait = "Scared", message = 
    Vocab.dialogues.intro.AnEvilJelly
  }
  
  script:closeDialogueWindow { id = 1 }
  
  -------------------------------------------------------------------------------------------------
  -- Move outside.
  -------------------------------------------------------------------------------------------------
  
  FieldManager.renderer:fadeout(150, true)
  FieldManager.renderer.images.BG2:setVisible(false)
  script:wait(60)
  
end