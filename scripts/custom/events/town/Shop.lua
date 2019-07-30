
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
    "Entrar na loja?"
  }

  script:openChoiceWindow { width = 80, choices = {
    "Sim.",
    "Não."
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
    
    script:showDialogue { id = 1, character = "Heron", portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
      "Olá, seja bem-vindo… "
    }
    
    script:showDialogue { id = 1, character = "Heron", portrait = "Blush", nameX = -0.45, nameY = -1.25, message = 
      "Ah, Tum Tum! Precisa de algo?"
    }
    
    script:showDialogue { id = 1, character = "player", portrait = "Happy", message = 
      "Olá, Heron! Preciso de algumas coisas, sim. Eu posso olhar a lista de itens?"
    }

    script:showDialogue { id = 1, character = "Heron", portrait = "Blush", nameX = -0.45, nameY = -1.25, message = 
      "C-claro! Não precisa pagar, pode pegar o que precisar, é por nossa conta!"
    }
    
    script:showDialogue { id = 1, character = "player", portrait = "Surprise", message = 
      "Ah, não, não! Não se preocupe com isso! Você se esforça muito, merece ser recompensado!"
    }
    
    script:showDialogue { id = 1, character = "player", portrait = "Determined", message = 
      "Vamos, eu quero ver o que tem!"
    }
  
    script:closeDialogueWindow { id = 1 }
    
    script:openShop (shop)
    
    script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
      width = ScreenManager.width, 
      height = ScreenManager.height / 3
    }
    
    script:showDialogue { id = 1, character = "Heron", portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
      "Muito obrigado, Tum Tum! Volte quando puder!"
    }
    
    script:showDialogue { id = 1, character = "player", portrait = "Happy", message = 
      "Não há de quê! Até mais!"
    }
    
    FieldManager.currentField.vars.shop = true
  
  else
    
    script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
      width = ScreenManager.width, 
      height = ScreenManager.height / 3
    }
    
    script:showDialogue { id = 1, character = "Heron", portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
      "Bem-vinda de volta, Tum Tum! Estamos à sua disposição!"
    }
    
    script:closeDialogueWindow { id = 1 }
    
    script:openShop (shop)
    
    script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
      width = ScreenManager.width, 
      height = ScreenManager.height / 3
    }
    
    script:showDialogue { id = 1, character = "Heron", portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
      "Obrigado e volte quando quiser!"
    }
    
  end
  
  script:closeDialogueWindow { id = 1 }
  
  script:fadeout { time = 90, wait = true }
  FieldManager.renderer.images.Shop:setVisible(false)
  script:fadein { time = 90, wait = true }

end
