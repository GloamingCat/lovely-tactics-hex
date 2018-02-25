
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
local LoadWindow = require('core/gui/start/window/LoadWindow')

---------------------------------------------------------------------------------------------------
-- Player
---------------------------------------------------------------------------------------------------

local Player_checkFieldInput = Player.checkFieldInput
function Player:checkFieldInput()
  if InputManager.keys['save']:isTriggered() then
    SaveManager:storeSave('quick')
  elseif InputManager.keys['load']:isTriggered() then
    SaveManager:loadSave('quick')
  else
    Player_checkFieldInput(self)
  end
end

---------------------------------------------------------------------------------------------------
-- LoadWindow
---------------------------------------------------------------------------------------------------

local LoadWindow_createWidgets = LoadWindow.createWidgets
function LoadWindow:createWidgets()
  self:createSaveButton('quick', Vocab.quickSave)
  LoadWindow_createWidgets(self)
end

local LoadWindow_rowCount = LoadWindow.rowCount
function LoadWindow:rowCount()
  return LoadWindow_rowCount(self) + 1
end