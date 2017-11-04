
--[[===============================================================================================

EndGUI
---------------------------------------------------------------------------------------------------
The GUI that is shown in the end of the battle.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local ResultWindow = require('core/gui/battle/window/ResultWindow')
local Vector = require('core/math/Vector')
local Text = require('core/graphics/Text')

-- Alias
local time = love.timer.getDelta

local EndGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------------------------------------

-- Overrides GUI:createWindows.
function EndGUI:createWindows()
  self.name = 'End GUI'
  self:createTopText()
  self:createMainWindow()
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
  self.topTextSpeed = 3
end
-- Creates the window that shows battle results.
function EndGUI:createMainWindow()
  local h = self.topText:getHeight() * self.topText.scaleY / Fonts.scale
  local window = ResultWindow(self, h, self.troop)
  self:setActiveWindow(window)
  self.windowList:add(window)
  self.mainWindow = window
  window:setActive()
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
  _G.Fiber:wait(30)
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
