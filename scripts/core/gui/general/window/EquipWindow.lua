
--[[===============================================================================================

EquipWindow
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local SimpleText = require('core/gui/SimpleText')
local Button = require('core/gui/Button')
local ListButtonWindow = require('core/gui/ListButtonWindow')

-- Alias
local max = math.max

local EquipWindow = class(ListButtonWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function EquipWindow:init(GUI, w, h, pos, rows, member)
  self.fitRowCount = rows
  ListButtonWindow.init(self, Config.equipTypes, GUI, w, h, pos)
  self.member = member
  self:createEquipTexts()
  self:setSelectedButton(nil)
end
-- @param(slot : table)
function EquipWindow:createListButton(slot)
  for i = 1, slot.count do
    local button = Button(self, self.onButtonConfirm)
    button:createText(slot.name, 'gui_medium')
    button.key = slot.key .. i
    button.equipType = slot.key
  end
end
-- Creates the texts with the current character's equiped items.
function EquipWindow:createEquipTexts()
  local w = self:buttonWidth()
  local x = w / 3
  w = w * 2 / 3
  for i = 1, #self.buttonMatrix do
    local button = self.buttonMatrix[i]
    local id = self.member.data.equipment[button.key]
    local name, icon = Vocab.empty, nil
    if id and id >= 0 then
      local item = Database.items[id]
      name = item.name
    end
    local pos = Vector(x, 1, 0)
    button:createInfoText(name, 'gui_medium', 'left', w, pos)
  end
end

function EquipWindow:setMember(member)
  
end

----------------------------------------------------------------------------------------------------
-- Button callbacks
----------------------------------------------------------------------------------------------------

function EquipWindow:onButtonConfirm(button)
  --self:setSelectedButton(nil)
  --self.GUI.itemWindow:activate()
end

function EquipWindow:onCancel()
  self:setSelectedButton(nil)
  self.GUI.listWindow:activate()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

function EquipWindow:colCount()
  return 1
end

function EquipWindow:rowCount()
  return self.fitRowCount
end

function EquipWindow:buttonWidth()
  return self.width - self:hPadding() * 2
end

function EquipWindow:__tostring()
  return 'EquipWindow'
end

return EquipWindow