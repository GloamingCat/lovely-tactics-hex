
--[[===============================================================================================

IntroWindow
---------------------------------------------------------------------------------------------------
Window that is shown in the beginning of the battle.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local ActionGUI = require('core/gui/battle/ActionGUI')
local PartyAction = require('core/battle/action/PartyAction')
local ActionInput = require('core/battle/action/ActionInput')
local GridWindow = require('core/gui/GridWindow')

local IntroWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Creates a button for each backup member.
function IntroWindow:createWidgets()
  self:addButton('start')
  self:addButton('party')
  --Button:fromKey(self, 'members')
end
-- Overriden to align text.
function IntroWindow:addButton(key)
  local button = Button(self, self[key .. 'Confirm'], self[key .. 'Select'], self[key .. 'Enabled'])
  local icon = Icons[key]
  if icon then
    button:createIcon(icon)
  end
  local text = Vocab[key]
  if text then
    button:createText(text, nil, 'center')
  end
  return button
end

---------------------------------------------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------------------------------------------

-- When player chooses Start button.
function IntroWindow:startConfirm(button)
  self.result = 1
end
-- When player chooses Party button.
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
-- When player chooses Items button.
function IntroWindow:membersConfirm(button)
  self:hide()
  -- TODO: choose member to manage
  self:show()
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
  return 2
end

return IntroWindow
