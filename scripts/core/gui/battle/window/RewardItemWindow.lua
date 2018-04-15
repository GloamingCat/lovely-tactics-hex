
--[[===============================================================================================

RewardItemWindow
---------------------------------------------------------------------------------------------------
The window that shows the list of gained items.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local InventoryWindow = require('core/gui/general/window/InventoryWindow')
local Vector = require('core/math/Vector')

-- Constants
local goldIcon = Config.icons.gold

local RewardItemWindow = class(InventoryWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(GUI : GUI) Parent GUI.
-- @param(w : width) The width of the window.
-- @param(h : height) The height of the window.
-- @param(pos : Vector) The position of the window's center.
function RewardItemWindow:init(GUI, w, h, pos)
  self.noCursor = true
  self.noHighlight = true
  self.gold = GUI.rewards.gold
  InventoryWindow.init(self, GUI, nil, GUI.rewards.items, nil, w, h, pos)
end
-- Overrides ListWindow:createWidgets.
-- Adds the Gold button.
function RewardItemWindow:createWidgets()
  local icon = goldIcon.id >= 0 and 
    ResourceManager:loadIconAnimation(goldIcon, GUIManager.renderer)
  local button = Button(self)
  button:createText(Vocab.gold, 'gui_medium')
  button:createIcon(icon)
  button:createInfoText(self.gold, 'gui_medium')
  InventoryWindow.createWidgets(self)
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- New col count.
function RewardItemWindow:colCount()
  return 1
end
-- @ret(string) String representation (for debugging).
function RewardItemWindow:__tostring()
  return 'Item Reward Window'
end

return RewardItemWindow