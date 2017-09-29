
--[[===============================================================================================

EquipGUI
---------------------------------------------------------------------------------------------------
The GUI that contains only a confirm window.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local GUI = require('core/gui/GUI')
local EquipSlotWindow = require('core/gui/general/window/EquipSlotWindow')
local EquipMemberWindow = require('core/gui/general/window/EquipMemberWindow')
local EquipItemWindow = require('core/gui/general/window/EquipItemWindow')
local DescriptionWindow = require('core/gui/general/window/DescriptionWindow')

local EquipGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function EquipGUI:createWindows()
  self.name = 'Equip GUI'
  self:createMemberWindow()
  self:createSlotWindow()
  self:createItemWindow()
  self:createDescriptionWindow()
  self:setActiveWindow(self.memberWindow)
end

function EquipGUI:createMemberWindow()
  local window = EquipMemberWindow(self, TurnManager:currentTroop())
  self.memberWindow = window
  self.windowList:add(window)
end

function EquipGUI:createSlotWindow()
  local member = self.memberWindow.buttonMatrix[1].member
  local w = ScreenManager.width - self.memberWindow.width * 2 - self:windowMargin() * 4
  local h = self.memberWindow.height
  local y = self:windowMargin() - ScreenManager.height / 2 + h / 2
  local window = EquipSlotWindow(self, w, h, Vector(0, y), self.memberWindow.fitRowCount, member)
  self.slotWindow = window
  self.windowList:add(window)
end

function EquipGUI:createItemWindow()
  local w = self.memberWindow.width
  local h = self.memberWindow.height
  local window = EquipItemWindow(self, w, h, self.memberWindow.fitRowCount, TurnManager:currentTroop())
  self.itemWindow = window
  self.windowList:add(window)
end

function EquipGUI:createDescriptionWindow()
  local w = ScreenManager.width - self:windowMargin() * 2
  local h = ScreenManager.height - self.memberWindow.height - self:windowMargin() * 3
  local pos = Vector(0, ScreenManager.height / 2 - h / 2 - self:windowMargin())
  local window = DescriptionWindow(self, w, h, pos)
  self.descriptionWindow = window
  self.windowList:add(window)
end

return EquipGUI
