
--[[===============================================================================================

Entrance
---------------------------------------------------------------------------------------------------
Tile to enter a certain place.
The arguments must include place's "name", which is the title shown above player, and "dest", which
is the field's transition that the loaded when player confirms, starting from 1.

=================================================================================================]]

return function(script)
	
	script:openTitleWindow { text = script.args.name }
  while not FieldManager.player:moving() do
    if not FieldManager.player:isBusy() then
      if InputManager.keys['confirm']:isTriggered() then
        script:closeTitleWindow()
        local t = FieldManager.currentField.transitions[tonumber(script.args.dest)]
        script:moveToField (t)
        return
      end
    end
    coroutine.yield()
  end
  script:closeTitleWindow()

end
