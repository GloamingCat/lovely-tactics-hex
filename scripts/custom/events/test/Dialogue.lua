
--[[===============================================================================================

Dialogue Test
---------------------------------------------------------------------------------------------------

=================================================================================================]]

return function(script)

  script:turnCharTile { key = 'self', other = 'player' }

  script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
    Vocab.dialogues.town.Hi
  }

  script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
    Vocab.dialogues.town.WhatsYourAge
  }

  script:openNumberWindow { length = 2 }

  script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
    Vocab.dialogues.town.OhMeToo .. "\n" ..
    Vocab.dialogues.town.HowAreYouDoing
  }

  script:openChoiceWindow { width = 50, choices = {
    Vocab.dialogues.town.Good,
    Vocab.dialogues.town.Bad
  }}

  if script.gui.choice == 1 then
    script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
      Vocab.dialogues.town.ThatsGood
    }
  else
    script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
      Vocab.dialogues.town.ThatsBad
    }
  end

  script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
    Vocab.dialogues.town.ImHungry
  }

  script:closeDialogueWindow { id = 1 }

end
