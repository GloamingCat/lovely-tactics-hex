
--[[===============================================================================================

RewardEXPWindow
---------------------------------------------------------------------------------------------------
The window that shows the gained experience.

=================================================================================================]]

-- Imports
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')

local RewardEXPWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function RewardEXPWindow:createContent(...)
  Window.createContent(self, ...)
  local font = Fonts.gui_medium
  local x = - self.width / 2 + self:hPadding()
  local y = - self.height / 2 + self:vPadding()
  local w = self.width - self:hPadding() * 2
  for k, v in pairs(self.GUI.rewards.exp) do
    local battler = self.GUI.troop.battlers[k]
    local posName = Vector(x, y)
    local name = SimpleText(battler.name, posName, w, 'left', font)
    local exp = battler.class.exp
    local value = SimpleText(exp .. '->' .. (exp + v), posName, w, 'right', font)
    self.content:add(name)
    self.content:add(value)
    y = y + 10
  end
end

function RewardEXPWindow:__tostring()
  return 'EXP Reward Window'
end

return RewardEXPWindow