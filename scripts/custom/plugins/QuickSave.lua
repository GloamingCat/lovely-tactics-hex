
--[[===============================================================================================

QuickSave
---------------------------------------------------------------------------------------------------
Adds keys the save/load any time.

=================================================================================================]]

KeyMap[args.saveKey] = 'save'
KeyMap[args.loadKey] = 'load'

local Player = require('core/objects/Player')

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
