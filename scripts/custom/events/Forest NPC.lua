--[[===============================================================================================

Forest NPC
---------------------------------------------------------------------------------------------------
Hero Mage NPC. Tests dialogue, shop and teleport.

=================================================================================================]]

script:turnCharTile{ key = "self", other = "player" }

script:openDialogueWindow { id = 1, width = 255, height = 60 }

script:showDialogue { id = 1, character = "HeroMage", portrait = "bigIcon", message = 
	"What do you want to do?"
}

script:openChoiceWindow { width = 80, choices = {
	"Shop.",
	"Talk.",
	"Enter city.",
  "Nothing."
}}

script:closeDialogueWindow { id = 1 }

if script.gui.choice == 1 then
	-- Shop Test
  script.root:forkFromScript { name = "events/test/Shop.lua" }
elseif script.gui.choice == 2 then
	-- Dialogue Test
	script.root:forkFromScript { name = "events/test/Dialogue.lua" }
elseif script.gui.choice == 3 then
	-- Teleport Test
  script.root:fork(function()
    script:moveToField { fade = 60, fieldID = 7, x = 6, y = 8, h = 1, direction = 270 }
  end)
end