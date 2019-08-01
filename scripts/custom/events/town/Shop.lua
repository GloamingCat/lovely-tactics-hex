
--[[===============================================================================================

Shop Test
---------------------------------------------------------------------------------------------------


=================================================================================================]]

return function(script)
  
  script:openDialogueWindow { id = 1, x = 0, y = -ScreenManager.height / 3,
    width = ScreenManager.width / 3,
    height = ScreenManager.height / 4
  }
  
  script:showDialogue { id = 1, character = '', message = 
    Vocab.dialogues.Shop
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

  script:fadeout { time = 90, wait = true }
  FieldManager.renderer.images.Shop:setVisible(true)
  script:fadein { time = 90, wait = true }
  
  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3
  }
  
  if not FieldManager.currentField.vars.shop then
    
    script:showDialogue { id = 1, character = 13, portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
      Vocab.dialogues.HelloWelcome
    }
    
    script:showDialogue { id = 1, character = 13, portrait = "Blush", nameX = -0.45, nameY = -1.25, message = 
      Vocab.dialogues.AhTumTum
    }
    
    script:showDialogue { id = 1, character = "player", portrait = "Happy", message = 
      Vocab.dialogues.HelloHeron
    }

    script:showDialogue { id = 1, character = 13, portrait = "Blush", nameX = -0.45, nameY = -1.25, message = 
      Vocab.dialogues.OfCourse
    }
    
    script:showDialogue { id = 1, character = "player", portrait = "Surprise", message = 
      Vocab.dialogues.OhNoDontWorry
    }
    
    script:showDialogue { id = 1, character = "player", portrait = "Determined", message = 
      Vocab.dialogues.CmonIWant
    }
  
    script:closeDialogueWindow { id = 1 }
    
    script:openShop (shop)
    
    script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
      width = ScreenManager.width, 
      height = ScreenManager.height / 3
    }
    
    script:showDialogue { id = 1, character = 13, portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
      Vocab.dialogues.ThankYouComeBack
    }
    
    script:showDialogue { id = 1, character = "player", portrait = "Happy", message = 
      Vocab.dialogues.YoureWelcome
    }
    
    FieldManager.currentField.vars.shop = true
  
  else
    
    script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
      width = ScreenManager.width, 
      height = ScreenManager.height / 3
    }
    
    script:showDialogue { id = 1, character = 13, portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
      Vocab.dialogues.WelcomeBack
    }
    
    script:closeDialogueWindow { id = 1 }
    
    script:openShop (shop)
    
    script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
      width = ScreenManager.width, 
      height = ScreenManager.height / 3
    }
    
    script:showDialogue { id = 1, character = 13, portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
      Vocab.dialogues.ThankYou
    }
    
  end
  
  script:closeDialogueWindow { id = 1 }
  
  script:fadeout { time = 90, wait = true }
  FieldManager.renderer.images.Shop:setVisible(false)
  script:fadein { time = 90, wait = true }

end
