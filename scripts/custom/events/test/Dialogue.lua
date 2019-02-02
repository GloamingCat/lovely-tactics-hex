--[[===============================================================================================

Dialogue Test
---------------------------------------------------------------------------------------------------

=================================================================================================]]

script:openDialogueWindow { id = 1, width = 255, height = 60 }

script:showDialogue { id = 1, character = "HeroMage", portrait = "bigIcon", message = 
	"Hi."
}

script:showDialogue { id = 1, character = "HeroMage", portrait = "bigIcon", message = 
	"What's your age?"
}

script:openNumberWindow { length = 2 }

script:showDialogue { id = 1, character = "HeroMage", portrait = "bigIcon", message = 
	"Oh, me too.\n" ..
	"How you {i}doing{r}? ~"
}

script:openChoiceWindow { width = 50, choices = {
	"Good.",
	"Bad."
}}

if script.gui.choice == 1 then
	script:showDialogue { id = 1, character = "HeroMage", portrait = "bigIcon", message = 
		"That's good."
	}
else
	script:showDialogue { id = 1, character = "HeroMage", portrait = "bigIcon", message = 
		"That's bad."
	}
end

script:showDialogue { id = 1, character = "HeroMage", portrait = "bigIcon", message = 
	"I'm hungry. Maybe I'll have some pudding."
}

script:closeDialogueWindow { id = 1 }