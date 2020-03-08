
--[[===============================================================================================

Forest - Pom Pom
---------------------------------------------------------------------------------------------------
Tum Tum and Blim Blim find Pom Pom. Second boss.

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
  local pom = script:findCharacter('PomPom')
  local boss = script:findCharacter('Boss')
  blim.speed = 120
  FieldManager.player.speed = 150
  
  AudioManager:pauseBGM(60)
  
  script:wait(30)

  script:showCharBalloon { key = 'player', emotion = '!' }
  script:showCharBalloon { key = 'BlimBlim', emotion = '!' }
  script:wait(60)
  
  local bossTile = boss:getTile()
  script:focusTile { x = bossTile.x, y = bossTile.y + 2, wait = true }
  script:wait(30)
  
  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Surprised", message = 
    Vocab.dialogues.dungeon.AhPomPom
  }
  
  script:closeDialogueWindow { id = 1 }
  
  script:focusCharacter { key = 'player', wait = true }
  script:fork(script.moveCharTile, script, { key = 'BlimBlim', x = -2, y = -2 })
  script:wait(10)
  boss:playIdleAnimation()
  script:wait(10)
  script:showCharBalloon { key = 'player', emotion = '!' }
  script:wait(15)
  script:moveCharTile { key = 'player', x = -1, y = -1 }
  script:fork(script.moveCharTile, script, { key = 'player', y = -1 })
  
  script:showDialogue { id = 1, character = "player", portrait = "Surprise", message = 
    Vocab.dialogues.dungeon.Careful
  }
  
  script:closeDialogueWindow { id = 1 }
  
  script:focusTile { x = bossTile.x, y = bossTile.y + 2, wait = true }
  script:wait(30)
  
  AudioManager.battleTheme = Sounds.bossTheme
  script:startBattle { fieldID = 25, fade = 60, intro = true, 
    gameOverCondition = 1, escapeEnabled = false }
  AudioManager.battleTheme = Sounds.battleTheme

  boss:playAnimation('Freeze')
  script:deleteChar { key = 'Boss', fade = 150, permanent = true, wait = true }
  
  script:wait(30)
  AudioManager:playSFX(Sounds.bump)
  pom:playAnimation('Bump')
  script:wait(15)
  pom:playAnimation('Idle')
  script:wait(60)
  script:showCharBalloon { key = 'PomPom', emotion = '?' }
  script:wait(90)
  
  script:showDialogue { id = 1, character = "PomPom", portrait = "Worried", message = 
    Vocab.dialogues.dungeon.WhatHappened
  }
  
  script:closeDialogueWindow { id = 1 }
  
  local w = ScreenManager.width / 2
  local h = ScreenManager.height / 3
  script:fork(function()
    script:showDialogue { id = 1, character = "BlimBlim", portrait = "Happy", width = w, x = w/2, message = 
      Vocab.dialogues.dungeon.PomPom
    }
    script:closeDialogueWindow { id = 1 }
  end)

  script:showDialogue { id = 2, character = "player", portrait = "Happy", width = w, x = -w/2, y = h, message = 
    Vocab.dialogues.dungeon.PomPom
  }
  
  script:closeDialogueWindow { id = 2 }
  
  script:focusTile { x = bossTile.x, y = bossTile.y, wait = true }
  blim.speed = 150
  script:fork(script.moveCharTile, script, { key = 'BlimBlim', y = -6 })
  script:wait(30)
  script:moveCharTile { key = 'player', y = -5 }
  script:turnCharTile { key = 'BlimBlim', other = 'PomPom' }
  script:moveCharTile { key = 'player', x = -1, y = -1 }
  script:turnCharTile { key = 'player', other = 'PomPom' }
  
  script:showDialogue { id = 1, character = "PomPom", portrait = "Sad", message = 
    Vocab.dialogues.dungeon.IFeelDizzy
  }

  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Determined", message = 
    Vocab.dialogues.dungeon.DontWorry
  }
  
  script:showDialogue { id = 1, character = "PomPom", portrait = "Sad", message = 
    Vocab.dialogues.dungeon.TheCat
  }
  
  script:showDialogue { id = 1, character = "BlimBlim", portrait = "Confused", message = 
    Vocab.dialogues.dungeon.WhatCat
  }
  
  script:closeDialogueWindow { id = 1 }
  
  script:showCharBalloon { key = 'PomPom', emotion = '!' }
  script:wait(90)
  
  script:showDialogue { id = 1, character = "PomPom", portrait = "Surprised", message = 
    Vocab.dialogues.dungeon.ISawHim
  }

  script:showDialogue { id = 1, character = "PomPom", portrait = "Worried", message = 
    Vocab.dialogues.dungeon.HeWasAsleep
  }

  script:showDialogue { id = 1, character = "PomPom", portrait = "Shy", message = 
    Vocab.dialogues.dungeon.GoodThing
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Surprise", message = 
    Vocab.dialogues.dungeon.SoACat
  }
  
  script:showDialogue { id = 1, character = "PomPom", portrait = "Sad", message = 
    Vocab.dialogues.dungeon.IDontKnow
  }
  
  script:showDialogue { id = 1, character = "player", portrait = "Focus", message = 
    Vocab.dialogues.dungeon.LetsGoFindHim
  }
  
  script:closeDialogueWindow { id = 1 }
  
  FieldManager.renderer:fadeout(150, true)
  FieldManager.renderer.focusObject = FieldManager.player
  FieldManager.player.speed = 104
  script:deleteChar { key = 'BlimBlim', permanent = true }
  script:deleteChar { key = 'PomPom', permanent = true }
  AudioManager:playBGM (Sounds.jungleTheme)
  script:addMember { key = 'PomPom' }
  FieldManager.renderer:fadein(180, true)
  
end
