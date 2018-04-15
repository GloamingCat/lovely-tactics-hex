
--[[===============================================================================================

InventoryGUI
---------------------------------------------------------------------------------------------------
The GUI to manage and use a item from party's inventory.

=================================================================================================]]

-- Imports
local DescriptionWindow = require('core/gui/general/window/DescriptionWindow')
local GUI = require('core/gui/GUI')
local InventoryWindow = require('core/gui/general/window/InventoryWindow')
local Vector = require('core/math/Vector')

local InventoryGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(memberGUI : MemberGUI) Parent GUI.
function InventoryGUI:init(troop)
  self.troop = troop
  self.name = 'Inventory GUI'
  GUI.init(self)
end
-- Overrides GUI:createWindows.
function InventoryGUI:createWindows()
  self:createItemWindow()
  self:createDescriptionWindow()
  self:setActiveWindow(self.mainWindow)
end
-- Creates the main item window.
function InventoryGUI:createItemWindow()
  local member = self.troop.current[1]
  local window = InventoryWindow(self, member, self.troop.inventory)
  self.mainWindow = window
end
-- Creates the item description window.
function InventoryGUI:createDescriptionWindow()
  local w = ScreenManager.width - self:windowMargin() * 2
  local h = ScreenManager.height - self.mainWindow.height - self:windowMargin() * 4
  local pos = Vector(0, ScreenManager.height / 2 - h / 2 - self:windowMargin())
  self.descriptionWindow = DescriptionWindow(self, w, h, pos)
end

return InventoryGUI