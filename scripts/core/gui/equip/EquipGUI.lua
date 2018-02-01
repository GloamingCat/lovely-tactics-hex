
--[[===============================================================================================

EquipGUI
---------------------------------------------------------------------------------------------------
The GUI to manage a character's equipment.

=================================================================================================]]

-- Imports
local DescriptionWindow = require('core/gui/general/window/DescriptionWindow')
local EquipSlotWindow = require('core/gui/equip/window/EquipSlotWindow')
local EquipItemWindow = require('core/gui/equip/window/EquipItemWindow')
local EquipBonusWindow = require('core/gui/equip/window/EquipBonusWindow')
local GUI = require('core/gui/GUI')
local Vector = require('core/math/Vector')

local EquipGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(memberGUI : MemberGUI) parent GUI
-- @param(y : number) top Y of the GUI
function EquipGUI:init(memberGUI, y)
  self.memberGUI = memberGUI
  self.name = 'Equip GUI'
  self.initY = y
  GUI.init(self)
end
-- Overrides GUI:createWindows.
function EquipGUI:createWindows()
  self:createSlotWindow()
  self:createItemWindow()
  self:createBonusWindow()
  self:createDescriptionWindow()
  self:setActiveWindow(self.slotWindow)
end
-- Creates the window with the battler's slots.
function EquipGUI:createSlotWindow()
  self.slotWindow = EquipSlotWindow(self)
end
-- Creates the window with the possible equipment items for a chosen slot.
function EquipGUI:createItemWindow()
  local w = self.slotWindow.width
  local h = self.slotWindow.height
  local pos = self.slotWindow.position
  self.itemWindow = EquipItemWindow(self, w, h, pos, self.slotWindow.visibleRowCount)
  self.itemWindow:setVisible(false)
end
-- Creates the window with the equipment's attribute and element bonus.
function EquipGUI:createBonusWindow()
  local w = ScreenManager.width - self.slotWindow.width - self:windowMargin() * 3
  local h = self.slotWindow.height
  local x = (ScreenManager.width - w) / 2 - self:windowMargin()
  local y = self.slotWindow.position.y
  self.bonusWindow = EquipBonusWindow(self, w, h, Vector(x, y))
  self.bonusWindow.member = self.memberGUI:currentMember()
end
-- Creates the window with the selected equipment item's description.
function EquipGUI:createDescriptionWindow()
  local w = ScreenManager.width - self:windowMargin() * 2
  local h = ScreenManager.height - self.initY - self.slotWindow.height - self:windowMargin() * 2
  local pos = Vector(0, ScreenManager.height / 2 - h / 2 - self:windowMargin())
  self.descriptionWindow = DescriptionWindow(self, w, h, pos)
end

---------------------------------------------------------------------------------------------------
-- Member
---------------------------------------------------------------------------------------------------

-- Changes the current chosen member.
-- @param(member : Battler)
function EquipGUI:setMember(member)
  self.bonusWindow:setMember(member)
  self.slotWindow:setMember(member)
  self.slotWindow:onButtonSelect(self.slotWindow:currentButton())
  self.itemWindow:setMember(member)
end

return EquipGUI