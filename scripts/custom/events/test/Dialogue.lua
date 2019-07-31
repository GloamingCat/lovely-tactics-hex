
--[[===============================================================================================

Dialogue Test
---------------------------------------------------------------------------------------------------

=================================================================================================]]

return function(script)

  script:turnCharTile { key = 'self', other = 'player' }

  script:openDialogueWindow { id = 1, width = 250, height = 60 }

  script:showDialogue { id = 1, character = "self", portrait = "BigIcon", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.Hi
  }

  script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
    Vocab.dialogues.WhatsYourAge
  }

  script:openNumberWindow { length = 2 }

  script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
    Vocab.dialogues.OhMeToo .. "\n" ..
    Vocab.dialogues.HowAreYouDoing
  }

  script:openChoiceWindow { width = 50, choices = {
    Vocab.dialogues.Good,
    Vocab.dialogues.Bad
  }}

  if script.gui.choice == 1 then
    script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
      Vocab.dialogues.ThatsGood
    }
  else
    script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
      Vocab.dialogues.ThatsBad
    }
  end

  script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
    Vocab.dialogues.ImHungry
  }

  script:closeDialogueWindow { id = 1 }

end
