
--[[===============================================================================================

ItemWindow
---------------------------------------------------------------------------------------------------
The window that shows the list of items to be used.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local InventoryWindow = require('core/gui/general/window/InventoryWindow')
local MenuTargetGUI = require('core/gui/general/MenuTargetGUI')
local Vector = require('core/math/Vector')

local ItemWindow = class(InventoryWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(GUI : GUI) Parent GUI.
function ItemWindow:init(GUI)
  local rowCount = 6
  local fith = rowCount * self:cellHeight() + self:paddingY() * 2
  local items = GUI.inventory:getUsableItems(2)
  InventoryWindow.init(self, GUI, nil, GUI.inventory, items, nil, fith, nil, rowCount)
end
-- Overrides ListWindow:createButtons.
function ItemWindow:createWidgets()
  if #self.list > 0 then
    InventoryWindow.createWidgets(self)
  else
    Button(self)
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- @param(member : Battler)
function ItemWindow:setMember(member)
  self.member = member
  for i = 1, #self.matrix do
    self.matrix[i]:updateEnabled()
    self.matrix[i]:refreshState()
  end
end
-- Updates buttons to match new state of the inventory.
function ItemWindow:refreshItems()
  local items = self.GUI.inventory:getUsableItems(2)
  self:refreshButtons(items)
end

---------------------------------------------------------------------------------------------------
-- Input handlers
---------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------
-- Item Skill
---------------------------------------------------------------------------------------------------

-- Overrides InventoryWindow:singleTargetItem.
function ItemWindow:singleTargetItem(input)
  local memberGUI = self.GUI.memberGUI
  GUIManager.fiberList:fork(memberGUI.hide, memberGUI)
  self.GUI:hide()
  local gui = MenuTargetGUI(self.member.troop)
  gui.input = input
  GUIManager:showGUIForResult(gui)
  self:refreshItems()
  GUIManager.fiberList:fork(memberGUI.show, memberGUI)
  _G.Fiber:wait()
  self.GUI:show()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- @ret(string) String representation (for debugging).
function ItemWindow:__tostring()
  return 'Menu Item Window'
end

return ItemWindow