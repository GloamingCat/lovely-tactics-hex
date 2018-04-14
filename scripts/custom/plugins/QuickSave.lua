
--[[===============================================================================================

QuickSave
---------------------------------------------------------------------------------------------------
Adds keys the save/load any time.

=================================================================================================]]

-- Arguments
KeyMap[args.saveKey] = 'save'
KeyMap[args.loadKey] = 'load'

-- Imports
local Player = require('core/objects/Player')
local PopupText = require('core/battle/PopupText')
local LoadWindow = require('core/gui/save/window/LoadWindow')

---------------------------------------------------------------------------------------------------
-- Player
---------------------------------------------------------------------------------------------------

local function popup(msg)
  GUIManager.fiberList:fork(function()
    local popup = PopupText(ScreenManager.width / 2 - 50, ScreenManager.height / 2, 0, 
      GUIManager.renderer)
    popup.align = 'right'
    popup:addLine(msg, 'white', 'gui_default')
    popup:popup()
  end)
end
-- Checks for the save/load input.
local Player_checkFieldInput = Player.checkFieldInput
function Player:checkFieldInput()
  if InputManager.keys['save']:isTriggered() then
    SaveManager:storeSave('quick')
    popup(Vocab.saved)
  elseif InputManager.keys['load']:isTriggered() then
    SaveManager:loadSave('quick')
    popup(Vocab.loaded)
  else
    Player_checkFieldInput(self)
  end
end

---------------------------------------------------------------------------------------------------
-- LoadWindow
---------------------------------------------------------------------------------------------------

-- Override to include quick save in the load options.
local LoadWindow_createWidgets = LoadWindow.createWidgets
function LoadWindow:createWidgets()
  self:createSaveButton('quick', Vocab.quickSave)
  LoadWindow_createWidgets(self)
end
-- Override.
local LoadWindow_rowCount = LoadWindow.rowCount
function LoadWindow:rowCount()
  return LoadWindow_rowCount(self) + 1
end