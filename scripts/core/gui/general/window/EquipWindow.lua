
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
  local x = 0
  for i = 1, #self.buttonMatrix do
    local button = self.buttonMatrix[i]
    x = max(button.text.sprite:getWidth(), x)
  end
  for i = 1, #self.buttonMatrix do
    local button = self.buttonMatrix[i]
    local id = self.member.data.equipment[button.key]
    local name, icon = Vocab.empty, nil
    if id and id >= 0 then
      local item = Database.items[id]
      name = item.name
    end
    self:createEquipText(button, name, x + 4, 'gui_medium')
  end
end
-- @param(button : Button)
-- @param(name : string)
-- @param(x : number)
-- @param(fontName : string) (optional)
function EquipWindow:createEquipText(button, name, x, fontName)
  local width = self:buttonWidth() - x
  if button.icon then
    local _, _, w = button.icon.sprite.quad:getViewport()
    width = width - w
  end
  local p = self:hPadding()
  local pos = Vector(x, 0, 0)
  pos:add(button.text.relativePosition)
  fontName = fontName or 'gui_button'
  local textSprite = SimpleText(name, pos, width - p - x, 'left', fontName and Font[fontName])
  textSprite.sprite:setColor(Color.gui_text_default)
  button.infoText = textSprite
  textSprite:hide()
  button.content:add(textSprite)
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

function EquipWindow:__tostring()
  return 'EquipWindow'
end

return EquipWindow