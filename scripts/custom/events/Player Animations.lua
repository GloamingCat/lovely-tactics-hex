
--[[===============================================================================================

Player Animations
---------------------------------------------------------------------------------------------------
Changes player's character animation set to the one in the argument "name".

=================================================================================================]]

return function(script)
	
	FieldManager.player:setAnimations(script.args.name)
  FieldManager.player:replayAnimation()

end
