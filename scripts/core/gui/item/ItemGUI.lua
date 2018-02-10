
--[[===============================================================================================

ItemGUI
---------------------------------------------------------------------------------------------------
The GUI to manage and use a item from party's inventory.

=================================================================================================]]

-- Imports
local DescriptionWindow = require('core/gui/general/window/DescriptionWindow')
local GUI = require('core/gui/GUI')
local ItemWindow = require('core/gui/item/window/ItemWindow')
local Vector = require('core/math/Vector')

local ItemGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(memberGUI : MemberGUI) parent GUI
-- @param(y : number) top Y of the GUI
function ItemGUI:init(memberGUI, y)
  self.memberGUI = memberGUI
  self.name = 'Equip GUI'
  self.initY = y
  self.inventory = memberGUI.troop.inventory
  GUI.init(self)
end
-- Overrides GUI:createWindows.
function ItemGUI:createWindows()
  self:createItemWindow()
  self:createDescriptionWindow()
  self:setActiveWindow(self.itemWindow)
end
-- Creates the main item window.
function ItemGUI:createItemWindow()
  self.itemWindow = ItemWindow(self, self.initY)
end
-- Creates the item description window.
function ItemGUI:createDescriptionWindow()
  local w = ScreenManager.width - self:windowMargin() * 2
  local h = ScreenManager.height - self.initY - self.itemWindow.height - self:windowMargin() * 2
  local pos = Vector(0, ScreenManager.height / 2 - h / 2 - self:windowMargin())
  self.descriptionWindow = DescriptionWindow(self, w, h, pos)
end
-- Called when player selects a member to use the item.
-- @param(member : Battler)
function ItemGUI:setMember(member)
  self.itemWindow:setMember(member)
end

return ItemGUI