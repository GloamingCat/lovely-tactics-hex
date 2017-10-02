
--[[===============================================================================================

InteractionTest
---------------------------------------------------------------------------------------------------
Tests the interaction functionality.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local DialogueWindow = require('core/gui/general/window/DialogueWindow')

---------------------------------------------------------------------------------------------------
-- Main function
---------------------------------------------------------------------------------------------------

return function(event)
  local gui = GUI()
  local window = DialogueWindow(GUI)
  gui.windowList:add(window)
  window:activate()
  GUIManager:showGUI(gui)
  window:showDialogue('Hi.')
  window:showDialogue('How you doing?')
  GUIManager:returnGUI()
end