
--[[===============================================================================================

IntroWindow
---------------------------------------------------------------------------------------------------
Window that is shown in the beginning of the battle.

=================================================================================================]]

-- Imports
local Button = require('core/gui/Button')
--local ItemGUI = require('core/gui/general/ItemGUI')
local EquipGUI = require('core/gui/equip/EquipGUI')
local ActionGUI = require('core/gui/battle/ActionGUI')
local PartyAction = require('core/battle/action/PartyAction')
local ActionInput = require('core/battle/action/ActionInput')
local GridWindow = require('core/gui/GridWindow')

local IntroWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Creates a button for each backup member.
function IntroWindow:createButtons()
  self:createButton('start')
  self:createButton('party')
  --self:createButton('items')
  self:createButton('equips')
end
-- Overrides GridWindow:createButton.
function IntroWindow:createButton(key)
  local button = Button(self, self[key .. 'Confirm'], self[key .. 'Select'], self[key .. 'Enabled'])
  local text = Vocab[key]
  if text then
    button:createText(text, 'gui_button', 'center')
  end
end

---------------------------------------------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------------------------------------------

function IntroWindow:startConfirm(button)
  self.result = 1
end

function IntroWindow:partyConfirm(button)
  -- Executes action grid selecting.
  local action = PartyAction()
  local input = ActionInput(action, nil, nil, nil, self.GUI)
  input.party = TroopManager.playerParty
  action:onSelect(input)
  self.GUI:hide()
  GUIManager:showGUIForResult(ActionGUI(input))
  local center = TroopManager.centers[input.party]
  FieldManager.renderer:moveToPoint(center.x, center.y)
  self.GUI:show()
end

function IntroWindow:itemsConfirm(button)
  self.GUI:hide()
  GUIManager:showGUIForResult(ItemGUI())
  self.GUI:show()
end

function IntroWindow:equipsConfirm(button)
  self.GUI:hide()
  GUIManager:showGUIForResult(EquipGUI())
  self.GUI:show()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function IntroWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function IntroWindow:rowCount()
  return 4
end

return IntroWindow