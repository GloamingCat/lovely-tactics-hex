
--[[===============================================================================================

EquipGUI
---------------------------------------------------------------------------------------------------
The GUI that contains only a confirm window.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local GUI = require('core/gui/GUI')
local EquipSlotWindow = require('core/gui/equip/window/EquipSlotWindow')
local EquipItemWindow = require('core/gui/equip/window/EquipItemWindow')
local EquipBonusWindow = require('core/gui/equip/window/EquipBonusWindow')
local DescriptionWindow = require('core/gui/general/window/DescriptionWindow')

local EquipGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function EquipGUI:init(memberGUI, y)
  self.troop = memberGUI.troop
  self.memberGUI = memberGUI
  self.name = 'Equip GUI'
  self.initY = y
  GUI.init(self)
end

function EquipGUI:createWindows()
  self:createSlotWindow()
  self:createItemWindow()
  self:createBonusWindow()
  self:createDescriptionWindow()
  self:setActiveWindow(self.slotWindow)
end

function EquipGUI:createSlotWindow()
  self.slotWindow = EquipSlotWindow(self)
end

function EquipGUI:createItemWindow()
  local w = self.slotWindow.width
  local h = self.slotWindow.height
  local pos = self.slotWindow.position
  self.itemWindow = EquipItemWindow(self, w, h, pos, self.slotWindow.visibleRowCount)
  self.itemWindow:setVisible(false)
end

function EquipGUI:createBonusWindow()
  local w = ScreenManager.width - self.slotWindow.width - self:windowMargin() * 3
  local h = self.slotWindow.height
  local x = (ScreenManager.width - w) / 2 - self:windowMargin()
  local y = self.slotWindow.position.y
  self.bonusWindow = EquipBonusWindow(self, w, h, Vector(x, y))
end

function EquipGUI:createDescriptionWindow()
  local w = ScreenManager.width - self:windowMargin() * 2
  local h = ScreenManager.height - self.initY - self.slotWindow.height - self:windowMargin() * 2
  local pos = Vector(0, ScreenManager.height / 2 - h / 2 - self:windowMargin())
  self.descriptionWindow = DescriptionWindow(self, w, h, pos)
end

---------------------------------------------------------------------------------------------------
-- Member
---------------------------------------------------------------------------------------------------

function EquipGUI:setMember(member)
  self.slotWindow:setMember(member)
  self.itemWindow:setMember(member)
  -- TODO: update description window
end

return EquipGUI