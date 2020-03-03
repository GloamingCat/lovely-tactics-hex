
--[[===============================================================================================

Forest - Blim Blim
---------------------------------------------------------------------------------------------------
Tum Tum finds Blim Blim. First boss.

=================================================================================================]]

return function(script)
  
  FieldManager.currentField.loadScript = {
    global = false,
    block = true,
    wait = true,
    onLoad = true,
    onInteract = false,
    onCollide = false,
    name = "events/Player Animations.lua",
    tags = {
      key = "name",
      value = "Default"
    }
  }
  
  local blim = script:findCharacter('BlimBlim')
  local boss = script:findCharacter('Boss')
  blim.shadow:setVisible(false)
  
  AudioManager:pauseBGM(60)
  
  script:wait(30)

  script:showCharBalloon { key = 'player', emotion = '!' }
  script:wait(60)
  
  local bossTile = boss:getTile()
  script:focusTile { x = bossTile.x, y = bossTile.y - 1, wait = true }
  script:wait(30)
  
  script:showDialogue { id = 1, character = "player", portrait = "Surprise", message = 
    Vocab.dialogues.dungeon.OhFinally
  }
  
  script:closeDialogueWindow { id = 1 }

  FieldManager.player.speed = 80
  script:focusCharacter { key = 'player', wait = true }
  script:moveCharTile { key = 'player', y = 3, wait = true }

  script:showCharBalloon { key = 'player', emotion = '...' }
  script:wait(90)
  
  script:showDialogue { id = 1, character = "player", portrait = "Wonder", message = 
    Vocab.dialogues.dungeon.MaybeICan
  }
  
  script:closeDialogueWindow { id = 1 }
  
  boss:playIdleAnimation()
  script:wait(30)
  FieldManager.player:jump(30)
  script:showCharBalloon { key = 'player', emotion = '!' }
  script:wait(90)

  script:showDialogue { id = 1, character = "player", portrait = "Cry", message = 
    Vocab.dialogues.dungeon.OhOh
  }
  
  script:closeDialogueWindow { id = 1 }
  
  AudioManager.battleTheme = Sounds.bossTheme
  script:startBattle { fieldID = 14, fade = 60, intro = true, 
    gameOverCondition = 1, escapeEnabled = false }
  AudioManager.battleTheme = Sounds.battleTheme

  boss:playAnimation('Freeze')
  script:deleteChar { key = 'Boss', fade = 150, permanent = true, wait = true }
  
  script:wait(30)
  AudioManager:playSFX(Sounds.allyKO)
  blim.shadow:setVisible(true)
  blim:playAnimation('Sleeping')
  script:wait(30)

  script:showDialogue { id = 1, character = "player", portrait = "Cry", message = 
    Vocab.dialogues.dungeon.BlimBlim
  }
  
  script:closeDialogueWindow { id = 1 }
  
  FieldManager.player.speed = 120
  script:moveCharTile { key = 'player', y = 3, wait = true }

  script:showDialogue { id = 1, character = "player", portrait = "Worry", message = 
    Vocab.dialogues.dungeon.BlimAreYou
  }
  
  script:closeDialogueWindow { id = 1 }
  
  script:showCharBalloon { key = 'BlimBlim', emotion = '...' }
  script:wait(120)
  
  blim:playAnimation('Idle')
  script:showCharBalloon { key = 'BlimBlim', emotion = '!' }
  
  blim:jump(30)
  script:wait(90)
  
  blim:playAnimation('LookAround')
  
  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Angry", message = 
    Vocab.dialogues.dungeon.WhereIsIt
  }
  
  script:closeDialogueWindow { id = 1 }
  
  blim:playAnimation("Idle")
  blim:setDirection(45)
  script:wait(60)
  blim:setDirection(315)
  script:showCharBalloon { key = 'BlimBlim', emotion = '?' }
  script:wait(120)
  blim:setDirection(135)

  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Confused", message = 
    Vocab.dialogues.dungeon.DidItRun
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Wonder", message = 
    Vocab.dialogues.dungeon.WhichOne
  }
  
  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Angry", message = 
    Vocab.dialogues.dungeon.Swallowed
  }
  
  script:closeDialogueWindow { id = 1 }
  
  script:showCharBalloon { key = 'BlimBlim', emotion = '!' }
  script:wait(90)
  
  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Cry", message = 
    Vocab.dialogues.dungeon.NowIRemember
  }
  
  script:closeDialogueWindow { id = 1 }
  
  blim:playAnimation('LookAround')
  script:wait(60)
  
  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Angry", message = 
    Vocab.dialogues.dungeon.ImGonnaFinishIt
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Happy", message = 
    Vocab.dialogues.dungeon.AlreadyGot
  }
  
  blim:playAnimation('Idle')
  blim:setDirection(135)
  
  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Surprised", message = 
    Vocab.dialogues.dungeon.WhatSad
  }
  
  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Cry", message = 
    Vocab.dialogues.dungeon.NoFun
  }
  
  script:closeDialogueWindow { id = 1 }
  
  script:showCharBalloon { key = 'BlimBlim', emotion = '...' }
  script:wait(120)

  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Confused", message = 
    Vocab.dialogues.dungeon.PomPom
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Worry", message = 
    Vocab.dialogues.dungeon.NoShe
  }
  
  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Scared", message = 
    Vocab.dialogues.dungeon.WhatScared
  }
  
  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Determined", message = 
    Vocab.dialogues.dungeon.OkLets
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Normal", message = 
    Vocab.dialogues.dungeon.Yeah
  }
  
  script:closeDialogueWindow { id = 1 }
  
  FieldManager.renderer:fadeout(150, true)
  script:deleteChar { key = 'BlimBlim', permanent = true }
  AudioManager:playBGM (Sounds.fieldsTheme)
  script:addMember { key = 'BlimBlim' }
  FieldManager.renderer:fadein(180, true)
  
end
