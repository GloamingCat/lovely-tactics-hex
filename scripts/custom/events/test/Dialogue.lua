
--[[===============================================================================================

Dialogue Test
---------------------------------------------------------------------------------------------------

=================================================================================================]]

return function(script)

  script:turnCharTile { key = 'self', other = 'player' }

  script:openDialogueWindow { id = 1, width = 255, height = 60 }

  script:showDialogue { id = 1, character = "self", portrait = "BigIcon", nameX = -0.45, nameY = -1.25, message = 
    "Hi."
  }

  script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
    "What's your age?"
  }

  script:openNumberWindow { length = 2 }

  script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
    "Oh, me too.\n" ..
    "How you {i}doing{r}? ~"
  }

  script:openChoiceWindow { width = 50, choices = {
    "Good.",
    "Bad."
  }}

  if script.gui.choice == 1 then
    script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
      "That's good."
    }
  else
    script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
      "That's bad."
    }
  end

  script:showDialogue { id = 1, character = "self", portrait = "BigIcon", message = 
    "I'm hungry. Maybe I'll have some pudding."
  }

  script:closeDialogueWindow { id = 1 }

end
