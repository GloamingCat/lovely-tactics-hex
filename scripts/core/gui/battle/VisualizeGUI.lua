
--[[===============================================================================================

VisualizeGUI
---------------------------------------------------------------------------------------------------
GUI that is shown when player selects a battler during Visualize action.

=================================================================================================]]

-- Imports
local BattlerWindow = require('core/gui/common/window/BattlerWindow')
local GUI = require('core/gui/GUI')

local VisualizeGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(character : Character) Member's character in the battle field.
function VisualizeGUI:init(character)
  self.name = 'Visualize GUI'
  self.character = character
  GUI.init(self)
end
-- Override GUI:createWindows.
function VisualizeGUI:createWindows()
  local mainWindow = BattlerWindow(self)
  mainWindow:setMember(self.character.battler)
  self:setActiveWindow(mainWindow)
end

return VisualizeGUI
