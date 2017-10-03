
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
  local window = DialogueWindow(GUI, 225, 60)
  gui.windowList:add(window)
  window:activate()
  GUIManager:showGUI(gui)
  local portrait = { id = 44, col = 0, row = 0 }
  window:setPortrait(portrait)
  window:showDialogue('Hi.')
  window:showDialogue('How you doing?')
  GUIManager:returnGUI()
end