
--[[===============================================================================================

Player Animations
---------------------------------------------------------------------------------------------------
Changes player's character animation set to the one in the argument "name".
Used to switch to world map graphics when player exits a dungeon or town.
Should be also called when entering the first map of each dungeon/town.

=================================================================================================]]

return function(script)
	
	FieldManager.player:setAnimations(script.args.name)
  FieldManager.player:replayAnimation()

end
