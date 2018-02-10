
--[[===============================================================================================

ItemWindow
---------------------------------------------------------------------------------------------------
The window that shows the list of items to be used.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')
local Button = require('core/gui/widget/Button')
local InventoryWindow = require('core/gui/general/window/InventoryWindow')
local ItemAction = require('core/battle/action/ItemAction')
local MenuTargetGUI = require('core/gui/general/MenuTargetGUI')
local Vector = require('core/math/Vector')

-- Constants
local defaultSkillID = Config.battle.itemSkillID

local ItemWindow = class(InventoryWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(GUI : GUI)
-- @param(y : number) space occupied by the member GUI
function ItemWindow:init(GUI, y)
  local rowCount = 6
  local fith = rowCount * self:cellHeight() + self:vPadding() * 2
  local pos = Vector(0, y - ScreenManager.height / 2 + fith / 2)
  local items = GUI.inventory:getUsableItems(2)
  self.initY = y
  InventoryWindow.init(self, GUI, GUI.inventory, items, nil, fith, pos, rowCount)
end
-- @param(member : Battler)
function ItemWindow:setMember(member)
  self.member = member
  for i = 1, #self.matrix do
    self.matrix[i]:updateEnabled()
  end
end
-- Creates a button from an item ID.
-- @param(id : number) the item ID
function ItemWindow:createListButton(itemSlot)
  local button = InventoryWindow.createListButton(self, itemSlot)
  local id = button.item.use.skillID
  id = id >= 0 and id or defaultSkillID
  button.skill = ItemAction:fromData(id, button.item)
end
-- Overrides ListButtonWindow:createButtons.
function ItemWindow:createWidgets()
  if #self.list > 0 then
    InventoryWindow.createWidgets(self)
  else
    Button(self)
  end
end

---------------------------------------------------------------------------------------------------
-- Input handlers
---------------------------------------------------------------------------------------------------

-- Called when player chooses an item.
-- @param(button : Button) the button selected
function ItemWindow:onButtonConfirm(button)
  local input = ActionInput(button.skill, self.member)
  if button.skill.radius > 1 then
    -- Use in all members
    input.targets = self.GUI.member.troop.current
    self.input.action:menuUse(self.input)
    self:refreshItems()
  else
    -- Choose a target
    local memberGUI = self.GUI.memberGUI
    GUIManager.fiberList:fork(memberGUI.hide, memberGUI)
    self.GUI:hide()
    local gui = MenuTargetGUI(self.member.troop)
    gui.input = input
    GUIManager:showGUIForResult(gui)
    self:refreshItems()
    GUIManager.fiberList:fork(memberGUI.show, memberGUI)
    self.GUI:show()
  end
end
-- Called when player presses "next" key.
function ItemWindow:onNext()
  self.GUI.memberGUI:nextMember()
end
-- Called when player presses "prev" key.
function ItemWindow:onPrev()
  self.GUI.memberGUI:prevMember()
end
-- Tells if an item can be used.
-- @param(button : Button) the button to check
-- @ret(boolean)
function ItemWindow:buttonEnabled(button)
  return button.skill and button.skill:canMenuUse(self.member)
end
-- Updates buttons to match new state of the inventory.
function ItemWindow:refreshItems()
  local items = self.GUI.inventory:getUsableItems(2)
  self:refreshButtons(items)
  self:packWidgets()
end

return ItemWindow