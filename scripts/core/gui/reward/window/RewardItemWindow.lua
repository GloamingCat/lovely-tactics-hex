
--[[===============================================================================================

RewardItemWindow
---------------------------------------------------------------------------------------------------
The window that shows the list of gained items.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local InventoryWindow = require('core/gui/general/window/InventoryWindow')

local RewardItemWindow = class(InventoryWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function RewardItemWindow:init(GUI, w, h, pos)
  self.noCursor = true
  self.noHighlight = true
  InventoryWindow.init(self, GUI, GUI.rewards.items, nil, w, h, pos)
end

function RewardItemWindow:__tostring()
  return 'Item Reward Window'
end

return RewardItemWindow