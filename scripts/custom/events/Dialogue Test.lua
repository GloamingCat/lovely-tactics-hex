--[[===============================================================================================

Dialogue Test
---------------------------------------------------------------------------------------------------

=================================================================================================]]

event:openDialogueWindow { id = 1, width = 255, height = 60 }

event:showDialogue { id = 1, character = "HeroMage", portrait = "smallIcon", message = 
	"Hi."
}

event:showDialogue { id = 1, character = "HeroMage", portrait = "smallIcon", message = 
	"What's your age?"
}

event:openNumberWindow { length = 2 }

event:showDialogue { id = 1, character = "HeroMage", portrait = "smallIcon", message = 
	"Oh, me too.\n" +
	"How you {i}doing{r}? ~"
}

event:openChoiceWindow { width = 50, choices = {
	"Good.",
	"Bad."
}}

if event.gui.choice == 1 then
	event:showDialogue { id = 1, character = "HeroMage", portrait = "smallIcon", message = 
		"That's good."
	}
else
	event:showDialogue { id = 1, character = "HeroMage", portrait = "smallIcon", message = 
		"That's bad."
	}
end

event:showDialogue { id = 1, character = "HeroMage", portrait = "smallIcon", message = 
	"I'm hungry. Maybe I'll have some pudding."
}

event:closeDialogueWindow { id = 1 }