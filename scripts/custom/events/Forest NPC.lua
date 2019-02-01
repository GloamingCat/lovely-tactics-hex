--[[===============================================================================================

Forest NPC
---------------------------------------------------------------------------------------------------

=================================================================================================]]

::HeroMage::

event:turnCharTile{ key = "self", other = "player" }

event:openDialogueWindow { id = 1, width = 255, height = 60 }

event:showDialogue { id = 1, character = "HeroMage", portrait = "smallIcon", message = 
	"What do you want to do?"
}

event:openChoiceWindow { width = 50, choices = {
	"Shop.",
	"Talk.",
	"Enter city."
}}

event:closeDialogueWindow { id = 1 }

if event.gui.choice == 1 then
	-- Shop Test
	event:callEvent { id = 4 }
elseif event.gui.choice == 2 then
	-- Dialogue Test
	event:callEvent { id = 1 }
else
	-- Teleport Test
	event:teleportPlayer { fade = 60, fieldID = 7, x = 0, y = 0, h = 0, direction = 3 }
end