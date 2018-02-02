
local Vector = require('core/math/Vector')
local InventoryWindow = require('core/gui/general/window/InventoryWindow')

local ItemWindow = class(InventoryWindow)

function ItemWindow:init(GUI, w, h, pos)
  InventoryWindow.init(self, GUI, GUI.rewards.items, nil, w, h, pos)
end

function ItemWindow:__tostring()
  return 'Item Reward Window'
end

return ItemWindow