
--[[===============================================================================================

DebugBox
---------------------------------------------------------------------------------------------------
Shows a text box to enter any executable Lua script. If the script has any outputs, it will be
shown at the console.

=================================================================================================]]

-- Imports
local Player = require('core/objects/Player')
local TextInputGUI = require('core/gui/common/TextInputGUI')

-- Parameters
KeyMap.main['debug'] = args.key

---------------------------------------------------------------------------------------------------
-- Player
---------------------------------------------------------------------------------------------------

-- Checks for the debug key input.
local Player_checkFieldInput = Player.checkFieldInput
function Player:checkFieldInput()
  if InputManager.keys['debug']:isTriggered() then
    self:openDebugGUI()
  else
    Player_checkFieldInput(self)
  end
end
-- Show debug text box.
function Player:openDebugGUI()
  self:playIdleAnimation()
  AudioManager:playSFX(Sounds.menu)
  print('Debug window open.')
  local result = GUIManager:showGUIForResult(TextInputGUI(nil, "Type code.", true, true))
  if result and result ~= 0 then
    print('Executing: ' .. result)
    local output = loadstring(result)()
    print('Output: ' .. tostring(output))
  end
end
