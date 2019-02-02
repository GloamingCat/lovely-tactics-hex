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

script:openChoiceWindow { width = 50, choices = {
	"Shop.",
	"Talk.",
	"Enter city."
}}

script:closeDialogueWindow { id = 1 }

if script.gui.choice == 1 then
	-- Shop Test
  script.root:forkFromScript { name = "events/test/Shop.lua" }
elseif script.gui.choice == 2 then
	-- Dialogue Test
	script.root:forkFromScript { name = "events/test/Dialogue.lua" }
else
	-- Teleport Test
	--script:teleportPlayer { fade = 60, fieldID = 7, x = 0, y = 0, h = 0, direction = 3 }
  -- TODO
end