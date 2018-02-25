
--[[===============================================================================================

TitleCommandWindow
---------------------------------------------------------------------------------------------------
The small windows with the commands for character management.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')

local TitleCommandWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------------------------------

-- Constructor.
function TitleCommandWindow:init(...)
  self.noHighlight = true
  self.noSkin = true
  self.speed = math.huge
  GridWindow.init(self, ...)
end
-- Implements GridWindow:createWidgets.
function TitleCommandWindow:createWidgets()
  Button:fromKey(self, 'newGame')
  Button:fromKey(self, 'loadGame')
  Button:fromKey(self, 'quit')
end

---------------------------------------------------------------------------------------------------
-- Confirm Callbacks
---------------------------------------------------------------------------------------------------

-- New Game button.
function TitleCommandWindow:newGameConfirm()
  self.GUI:hide()
  self.result = 1
  SaveManager:newSave()
end
-- Load Game button.
function TitleCommandWindow:loadGameConfirm()
  self:hide()
  local result = self.GUI:showWindowForResult(self.GUI.loadWindow)
  if result ~= '' then
    self.result = 1
    self.GUI:hide()
    SaveManager:loadSave(result)
  else
    self:show()
  end
end
-- Quit button.
function TitleCommandWindow:quitConfirm()
  self.GUI:hide()
  GameManager:close()
end
-- Cancel button.
function TitleCommandWindow:onButtonCancel()
end

---------------------------------------------------------------------------------------------------
-- Enabled Conditions
---------------------------------------------------------------------------------------------------

-- @ret(boolean) True if Item GUI may be open, false otherwise.
function TitleCommandWindow:loadGameEnabled()
  return self.GUI.loadWindow
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function TitleCommandWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function TitleCommandWindow:rowCount()
  return 3
end
-- @ret(string) String representation (for debugging).
function TitleCommandWindow:__tostring()
  return 'Title Command Window'
end

return TitleCommandWindow