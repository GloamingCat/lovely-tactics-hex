
--[[===============================================================================================

EndGUI
---------------------------------------------------------------------------------------------------
The GUI that is shown in the end of the battle.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local RewardEXPWindow = require('core/gui/reward/window/RewardEXPWindow')
local RewardItemWindow = require('core/gui/reward/window/RewardItemWindow')
local Vector = require('core/math/Vector')
local Text = require('core/graphics/Text')

-- Alias
local time = love.timer.getDelta
local floor = math.floor

local EndGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------------------------------------

-- Overrides GUI:createWindows.
function EndGUI:createWindows()
  self.name = 'End GUI'
  self:createTopText()
  -- Reward windows
  local w = (ScreenManager.width - self:windowMargin() * 3) / 2
  local h = ScreenManager.height - self.topText:getHeight() - self:windowMargin() * 3
  local x = ScreenManager.width / 2 - w / 2 - self:windowMargin()
  local y = ScreenManager.height / 2 - h / 2 - self:windowMargin()
  self.troop = TroopManager:getPlayerTroop()
  self.rewards = self.troop:getBattleRewards()
  self:createEXPWindow(x, y, w, h)
  self:createItemWindow(x, y, w, h)
  self:setActiveWindow(self.expWindow)
  self.troop:addRewards(self.rewards)
end
-- Creates the text at the top of the screen to show that the player won.
function EndGUI:createTopText()
  local prop = {
    ScreenManager.width,
    'center',
    Fonts.gui_big }
  self.topText = Text(Vocab.win, prop, GUIManager.renderer)
  local x = -ScreenManager.width / 2
  local y = -ScreenManager.height / 2 + self:windowMargin() * 2
  self.topText:setXYZ(x, y)
  self.topText:setVisible(false)
  self.topTextSpeed = 8
end
-- Creates the window that shows battle results.
function EndGUI:createEXPWindow(x, y, w, h)
  local pos = Vector(-x, y)
  local window = RewardEXPWindow(self, w, h, pos)
  self.expWindow = window
end
-- Creates the window that shows battle results.
function EndGUI:createItemWindow(x, y, w, h)
  local pos = Vector(x, y)
  local window = RewardItemWindow(self, w, h, pos)
  self.itemWindow = window
end

function EndGUI:destroy(...)
  GUI.destroy(self, ...)
  self.topText:destroy()
end

---------------------------------------------------------------------------------------------------
-- Show
---------------------------------------------------------------------------------------------------

-- Show top text before openning windows.
function EndGUI:show(...)
  self:showTopText()
  _G.Fiber:wait(15)
  GUI.show(self, ...)
end
-- Animation that shows the text at the top.
function EndGUI:showTopText()
  local a = 0
  self.topText:setVisible(true)
  self.topText:setRGBA(nil, nil, nil, 0)
  while a < 255 do
    a = a + time() * 60 * self.topTextSpeed
    self.topText:setRGBA(nil, nil, nil, a)
    coroutine.yield()
  end
  self.topText:setRGBA(nil, nil, nil, 255)
end

---------------------------------------------------------------------------------------------------
-- Hide
---------------------------------------------------------------------------------------------------

-- Hide top text after closing windows.
function EndGUI:hide(...)
  GUI.hide(self, ...)
  self:hideTopText()
end
-- Animation that shows the text at the top.
function EndGUI:hideTopText()
  local a = 255
  while a > 0 do
    a = a - time() * 60 * self.topTextSpeed
    self.topText:setRGBA(nil, nil, nil, a)
    coroutine.yield()
  end
  self.topText:setVisible(false)
end

return EndGUI
