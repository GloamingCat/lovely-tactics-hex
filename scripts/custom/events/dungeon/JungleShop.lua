
--[[===============================================================================================

Jungle Shop
---------------------------------------------------------------------------------------------------


=================================================================================================]]

return function(script)
  
  script:turnCharTile { key = 'self', other = 'player' }
  
  script:showDialogue { id = 1, character = "Milkzkin", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.dungeon.JungleShop
  }
  
  script:closeDialogueWindow { id = 1 }
    
  local shop = { sell = true, items = {
    { id = 2 },
    { id = 3 },
    { id = 4 },
    { id = 5 },
    { id = 6 },
    { id = 7 }
  }}

  script:openShopMenu (shop)

  script:showDialogue { id = 1, character = "Milkzkin", nameX = -0.45, nameY = -1.25, message = 
    Vocab.dialogues.dungeon.ShopThanks
  }
  
  script:closeDialogueWindow { id = 1 }

end
