
--[[===============================================================================================

Inn
---------------------------------------------------------------------------------------------------

=================================================================================================]]

return function(script)

  script:openDialogueWindow { id = 1, x = 0, y = -ScreenManager.height / 3,
    width = ScreenManager.width / 3,
    height = ScreenManager.height / 4
  }
  
  script:showDialogue { id = 1, character = '', message = 
    Vocab.dialogues.Rest
  }

  script:openChoiceWindow { width = 80, choices = {
    Vocab.yes,
    Vocab.no
  }}

  script:closeDialogueWindow { id = 1 }

  if script.gui.choice == 2 then
    return
  end
  
  script:fadeout { time = 60, wait = true }
  AudioManager:playSFX { name = "sfx/GameAudio/heal.wav", pitch = 100, volume = 100 }
  script:wait(90)
  script:healAll {}
  FieldManager.renderer.images.Inn:setVisible(true)
  
  script:fadein { time = 60, wait = true }

  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3 
  }

  script:showDialogue { id = 1, character = 5, portrait = "Serious", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.YouMayReturn
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.DontWorry
  }
  
  script:closeDialogueWindow { id = 1 }

  script:fadeout { time = 90, wait = true }
  FieldManager.renderer.images.Inn:setVisible(false)
  script:fadein { time = 90, wait = true }

end
