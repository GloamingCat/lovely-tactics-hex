
--[[===============================================================================================

Entrance
---------------------------------------------------------------------------------------------------
Tile to enter a certain place.
The arguments must include place's "name", which is the title shown above player, and "dest", which
is the field's transition that the loaded when player confirms, starting from 1.

=================================================================================================]]

local function enter(script)
  script:closeTitleWindow()
  local t = FieldManager.currentField.transitions[tonumber(script.args.dest)]
  script:moveToField (t)
  FieldManager.player.onEntrance = false
end

return function(script)
  if FieldManager.player.onEntrance then
    return
  end
  FieldManager.player.onEntrance = true
	script:openTitleWindow { text = script.args.name }
  while not FieldManager.player:moving() do
    if not FieldManager.player:isBusy() then
      if InputManager.keys['confirm']:isTriggered() then
        return enter(script)
      elseif InputManager.keys['mouse1']:isTriggered() then
        local playerTile = FieldManager.player:getTile()
        local x, y, h = InputManager.mouse:fieldCoord(playerTile.layer.height)
        if x == playerTile.x and y == playerTile.y then
          return enter(script)
        end
      end
    end
    coroutine.yield()
  end
  script:closeTitleWindow()
  FieldManager.player.onEntrance = false
end
