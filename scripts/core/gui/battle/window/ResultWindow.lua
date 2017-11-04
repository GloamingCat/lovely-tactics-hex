
local Vector = require('core/math/Vector')
local Window = require('core/gui/window')

local ResultWindow = class(Window)

function ResultWindow:init(GUI, dh, troop)
  self.troop = troop
  local m = GUI:windowMargin()
  local w = ScreenManager.width - m * 2
  local h = ScreenManager.height - m * 5 - dh
  local pos = Vector(0, (ScreenManager.height - h) / 2 - m, 0)
  Window.init(self, GUI, w, h, pos)
end

function ResultWindow:createContent(w, h)
  Window.createContent(self, w, h)
  
end

return ResultWindow