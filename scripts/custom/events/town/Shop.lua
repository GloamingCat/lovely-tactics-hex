
--[[===============================================================================================

Shop Test
---------------------------------------------------------------------------------------------------


=================================================================================================]]

return function(script)
  
  script:openDialogueWindow { id = 1, x = 0, y = -ScreenManager.height / 3,
    width = ScreenManager.width / 3,
    height = ScreenManager.height / 4
  }
  
  script:showDialogue { id = 1, character = 'player', message = 
    Vocab.dialogues.town.Shop
  }

  script:openChoiceWindow { width = 80, choices = {
    Vocab.yes,
    Vocab.no
  }}

  script:closeDialogueWindow { id = 1 }

  if script.gui.choice == 2 then
    return
  end
  
  local shop = { sell = true, items = {
    { id = 2 },
    { id = 3 },
    { id = 4 },
    { id = 5 },
    { id = 6 },
    { id = 7 }
  }}

  FieldManager.renderer:fadeout(90, true)
  FieldManager.renderer.images.Shop:setVisible(true)
  FieldManager.renderer:fadein(90, true)
  
  if not FieldManager.currentField.vars.shop then
    
    script:showDialogue { id = 1, character = 13, portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
      Vocab.dialogues.town.HelloWelcome
    }
    
    script:showDialogue { id = 1, character = 13, portrait = "Blush", nameX = -0.45, nameY = -1.25, message = 
      Vocab.dialogues.town.AhTumTum
    }
    
    script:showDialogue { id = 1, character = "player", portrait = "Happy", message = 
      Vocab.dialogues.town.HelloHeron
    }

    script:showDialogue { id = 1, character = 13, portrait = "Blush", nameX = -0.45, nameY = -1.25, message = 
      Vocab.dialogues.town.OfCourse
    }
    
    script:showDialogue { id = 1, character = "player", portrait = "Surprise", message = 
      Vocab.dialogues.town.OhNoDontWorry
    }
    
    script:showDialogue { id = 1, character = "player", portrait = "Determined", message = 
      Vocab.dialogues.town.CmonIWant
    }
  
    script:closeDialogueWindow { id = 1 }
    
    script:openShopMenu (shop)
    
    script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
      width = ScreenManager.width, 
      height = ScreenManager.height / 3
    }
    
    script:showDialogue { id = 1, character = 13, portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
      Vocab.dialogues.town.ThankYouComeBack
    }
    
    script:showDialogue { id = 1, character = "player", portrait = "Happy", message = 
      Vocab.dialogues.town.YoureWelcome
    }
    
    FieldManager.currentField.vars.shop = true
  
  else
    
    script:showDialogue { id = 1, character = 13, portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
      Vocab.dialogues.town.WelcomeBack
    }
    
    script:closeDialogueWindow { id = 1 }
    
    script:openShopMenu (shop)
    
    script:showDialogue { id = 1, character = 13, portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
      Vocab.dialogues.town.ThankYou
    }
    
  end
  
  script:closeDialogueWindow { id = 1 }
  
  FieldManager.renderer:fadeout(90, true)
  FieldManager.renderer.images.Shop:setVisible(false)
  FieldManager.renderer:fadein(90, true)

end
