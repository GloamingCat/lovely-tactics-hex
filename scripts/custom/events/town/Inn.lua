
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
    Vocab.dialogues.town.Rest
  }

  script:openChoiceWindow { width = 80, choices = {
    Vocab.yes,
    Vocab.no
  }}

  script:closeDialogueWindow { id = 1 }

  if script.gui.choice == 2 then
    return
  end
  
  FieldManager.renderer:fadeout(60, true)
  AudioManager:playSFX { name = "sfx/GameAudio/heal.wav", pitch = 100, volume = 100 }
  script:wait(90)
  script:healAll {}
  FieldManager.renderer.images.Inn:setVisible(true)
  
  FieldManager.renderer:fadein(60, true)

  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3 
  }

  script:showDialogue { id = 1, character = 5, portrait = "Serious", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.town.YouMayReturn
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.town.DontWorry
  }
  
  script:closeDialogueWindow { id = 1 }

  FieldManager.renderer:fadeout(90, true)
  FieldManager.renderer.images.Inn:setVisible(false)
  FieldManager.renderer:fadein(90, true)

end
