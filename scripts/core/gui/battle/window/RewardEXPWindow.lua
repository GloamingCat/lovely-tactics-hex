
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

-- Overrides Window:createContent.
function RewardEXPWindow:createContent(...)
  Window.createContent(self, ...)
  local font = Fonts.gui_medium
  local x = - self.width / 2 + self:paddingX()
  local y = - self.height / 2 + self:paddingY()
  local w = self.width - self:paddingX() * 2
  local title = SimpleText(Vocab.experience, Vector(x, y), w, 'center')
  self.content:add(title)
  y = y + 20
  for k, v in pairs(self.GUI.rewards.exp) do
    local battler = self.GUI.troop.battlers[k]
    -- Name
    local posName = Vector(x, y)
    local name = SimpleText(battler.name, posName, w, 'left', font)
    self.content:add(name)
    -- EXP - Arrow
    local arrowPos = Vector(x + w / 2, y - 2, 0)
    local arrow = SimpleText('→', arrowPos, w / 2, 'center')
    local exp = battler.class.exp
    local aw = arrow.sprite:getWidth()
    local expw = w / 4 - aw / 2
    self.content:add(arrow)
    -- EXP - Values
    local posEXP1 = Vector(x + w / 2, y)
    local posEXP2 = Vector(x + w / 2 + expw + arrow.sprite:getWidth(), y)
    local exp1 = SimpleText(exp .. '', posEXP1, expw, 'left', font)
    local exp2 = SimpleText((exp + v) .. '', posEXP2, expw, 'left', font)    
    self.content:add(exp1)
    self.content:add(exp2)
    local nextLevel = battler.class:levelup(v)
    if nextLevel then
      local levelup = SimpleText('Level ' .. nextLevel .. '!', Vector(x, y + 10), w, 'right', font)
      levelup.sprite:setColor(Color.green)
      self.content:add(levelup)
      y = y + 12
    end
    y = y + 12
  end
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides Window:hide.
function RewardEXPWindow:hide(...)
  AudioManager:playSFX(Config.sounds.buttonConfirm)
  Window.hide(self, ...)
end
-- @ret(string) String representation (for debugging).
function RewardEXPWindow:__tostring()
  return 'EXP Reward Window'
end

return RewardEXPWindow