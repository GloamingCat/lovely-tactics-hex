
local util = {}

function util.moveToField(event, transition, fade)
  if fade then
    FieldManager.renderer:fadeout(255 / fade)
    event.origin:walkToTile(event.tile:coordinates())
  end
  FieldManager:loadTransition(transition)
end

return util