
--[[===============================================================================================

Intro
---------------------------------------------------------------------------------------------------
Intro scene. Chita tells the background story.

=================================================================================================]]

return function(script)
  
  script:fadeout {}
  
  FieldManager.renderer.images.BG1:setVisible(true)
  
  Fiber:wait(30)
  
  -------------------------------------------------------------------------------------------------
  -- First part of the storytelling.
  -------------------------------------------------------------------------------------------------
  
  script:openDialogueWindow { id = 1, x = 0, y = 0,
    width = ScreenManager.width * 3 / 4, 
    height = ScreenManager.height / 3 
  }

  script:showDialogue { id = 1, character = '', message = 
    "O mundo de Hexalia desde sempre foi feito de amor, alegria e doçura. " ..
    "Ele foi criado e mantido pelas bruxas da prosperidade: Pom Pom, Blim Blim e Tum Tum."
  }
  
  script:showDialogue { id = 1, message = 
    "Nosso povo viveu em paz e harmonia durante séculos, pois sempre foi reinado por sentimentos positivos. " ..
    "A verdade é que as emoções negativas também existiam, mas eram muito raras. " ..
    "Todos achavam que era apenas lenda e que ninguém era capaz que sentir isso."
  }

  script:showDialogue { id = 1, message = 
    "Porém, depois de vários anos, para espanto de todos… descobrimos que essas emoções são, sim, sentidas. " ..
    "E descobrimos isso da pior forma…"
  }
  
  script:closeDialogueWindow { id = 1 }

  script:fadein { time = 300, wait = true }
  Fiber:wait(60)

  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3 
  }

  script:showDialogue { id = 1, character = "Chita", portrait = "Serious", nameX = -0.45, nameY = -1.25, message = 
    "Pois quando essas emoções são muito intensas, elas podem acabar se transformando em…"
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    " ...Gelatinas!"
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Happy", namex = -0.8, message = 
    "Êeee, gelatina!"
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    'Nada de "ê", essas gelatinas são do mal!'
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Wonder", message = 
    "Como pode comida ser do mal?"
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "FacePalm", message = 
    "..."
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    "Elas não são de comer, Tum Tum! Você só pensa em comida?!"
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Cry", message = 
    "Ai, é que eu tô com foooome…"
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    "Se concentre! Isso é muito sério!"
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Focus", message = 
    "Ok, ok!"
  }
  
  script:closeDialogueWindow { id = 1 }
  
  script:fadeout { time = 150, wait = true }
  Fiber:wait(60)
  
  -------------------------------------------------------------------------------------------------
  -- Second part of the storytelling.
  -------------------------------------------------------------------------------------------------
  
  script:openDialogueWindow { id = 1, x = 0, y = 0,
    width = ScreenManager.width * 3 / 4, 
    height = ScreenManager.height / 3 
  }
  
  script:showDialogue { id = 1, character = '', message = 
    "Ahem."
  }
  
  script:showDialogue { id = 1, message = 
    "Felizmente, as bruxas da prosperidade possuem o poder para combater as gelatinas do mal. " .. 
    "Sempre que uma gelatina surge, elas a desmancham, se livrando dos sentimentos negativos que carregava."
  }
  
  script:showDialogue { id = 1, message = 
    "Ou, pelo menos, assim era até recentemente…"
  }
  
  script:showDialogue { id = 1, message = 
    "Um dia, as gelatinas estavam tão poderosas que conseguiram vencer duas das bruxas da prosperidade, " .. 
    "Blim Blim e Pom Pom, que estão até agora presas por gelatina."
  }
  
  script:closeDialogueWindow { id = 1 }

  script:fadein { time = 150, wait = true }
  Fiber:wait(30)

  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3 
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Worry", nameX = -0.45, nameY = -1.25, message = 
    "Oh, não!"
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Serious", message = 
    "Já tentamos de tudo para reencontrá-las, mas não conseguimos. " .. 
    "Mas sabemos que a última vez que foram vistas foi na floresta."
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    "Você é nossa última esperança, Tum Tum! Resgate elas e lute contra as gelatinas!"
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Worry", message = 
    "Mas, mas… Eu não sei se consigo fazer isso sozinha!"
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    "Você não estará sozinha. Tem o apoio de todo o povo de Hexalia com você!"
  }
  
  script:closeDialogueWindow { id = 1 }
    
  -------------------------------------------------------------------------------------------------
  -- Heron shows up.
  -------------------------------------------------------------------------------------------------
  
  AudioManager:playSFX { name = "sfx/Kenney/door.ogg" }
  script:fadeout { time = 90, wait = true }
  AudioManager:playBGM(Sounds.battleTheme)
  FieldManager.renderer.images.BG1:setVisible(false)
  FieldManager.renderer.images.BG2:setVisible(true)
  script:fadein { time = 60, wait = true }
  
  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3 
  }
  
  script:showDialogue { id = 1, character = "Heron", portrait = "Scared", nameX = -0.45, nameY = -1.25, message = 
    "Ah!! Tum Tum, nos ajude!"
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    "O que houve?!"
  }
  
  script:showDialogue { id = 1, character = "Heron", portrait = "Scared", message = 
    "Uma gelatina conseguiu ultrapassar nossos muros de proteção!"
  }
  
  script:closeDialogueWindow { id = 1 }
  
  -------------------------------------------------------------------------------------------------
  -- Move outside.
  -------------------------------------------------------------------------------------------------
  
  script:fadeout { time = 150, wait = true }
  FieldManager.renderer.images.BG2:setVisible(false)
  script:wait(60)
  script:fadein { time = 180, wait = true }
  
  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3 
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Worry", nameX = -0.45, nameY = -1.25, message = 
    "O que eu faço, o que eu faço?"
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Shout", message = 
    "Se acalme e tenha foco! Eu estarei aqui para te orientar! Você vai conseguir!"
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Determined", message = 
    "*Respira* \nOk, eu vou conseguir!"
  }
  
  script:closeDialogueWindow { id = 1 }
  
  AudioManager.battleTheme = nil
  script:startBattle { fieldID = 11, fade = 90, intro = true, 
    gameOverCondition = 1, escapeEnabled = false }
  AudioManager.battleTheme = Sounds.battleTheme
  
  -------------------------------------------------------------------------------------------------
  -- After battle.
  -------------------------------------------------------------------------------------------------
  
  script:deleteChar { key = 'Jelly', fade = 90, permanent = true, wait = true }
  
  script:openDialogueWindow { id = 1, x = 0, y = ScreenManager.height / 3,
    width = ScreenManager.width, 
    height = ScreenManager.height / 3
  }
  
  script:showDialogue { id = 1, character = "Heron", portrait = "Happy", nameX = -0.45, nameY = -1.25, message = 
    "Muito obrigado, Tum Tum! Você é incrível!"
  }
  
  AudioManager:playBGM { name = 'bgm/Aaron Krogh/Happiness.ogg', volume = 100, pitch = 100 }
  
  Fiber:wait(30)
  local angle = 45
  while angle < 225 do
    angle = angle + 45
    script:turnCharDir { key = "player", angle = angle }
    Fiber:wait(4)
  end
  Fiber:wait(30)
  
  script:showDialogue { id = 1, character = "player", portrait = "Blush", message = 
    "Hahah, que nada!"
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Serious", message = 
    "Muito bem, Tum Tum. Acha que está preparada agora?"
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Wonder", message = 
    "Eu acho que…"
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Determined", message = 
    "Essas gelatinas vão ter que correr de mim, porque eu vou resgatar Blim Blim e Pom Pom!"
  }
  
  script:showDialogue { id = 1, character = "Chita", portrait = "Pleased", message = 
    "Muito melhor."
  }
  
  script:closeDialogueWindow { id = 1 }

  -------------------------------------------------------------------------------------------------
  -- Finish.
  -------------------------------------------------------------------------------------------------

  script:fadeout { time = 180, wait = true }
  script:deleteChar { key = 'Chita', permanent = true }
  script:deleteChar { key = 'Heron', permanent = true }
  script:turnCharDir { key = "player", angle = 270 }
  Fiber:wait(30)
  AudioManager:playBGM { name = 'bgm/Gyrowolf/Town001.ogg', volume = 100, pitch = 100 }
  script:fadein { time = 180, wait = true }
  
  FieldManager.currentField.loadScript = { name = '' }
  
end
