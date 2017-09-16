
--[[===============================================================================================

ItemWindow
---------------------------------------------------------------------------------------------------
The GUI that is open to choose an item from character's inventory.

=================================================================================================]]

-- Imports
local ListButtonWindow = require('core/gui/ListButtonWindow')
local ActionWindow = require('core/gui/battle/window/ActionWindow')
local ItemAction = require('core/battle/action/ItemAction')
local Vector = require('core/math/Vector')
local Button = require('core/gui/Button')

-- Constants
local defaultSkillID = Config.battle.itemSkillID

local ItemWindow = class(ActionWindow, ListButtonWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function ItemWindow:init(GUI, inventory, itemList)
  ListButtonWindow.init(self, itemList, GUI)
  self.inventory = inventory
end
-- Creates a button from an item ID.
-- @param(id : number) the item ID
function ItemWindow:createButton(itemSlot)
  local item = Database.items[itemSlot.id]
  local icon = item.icon.id >= 0 and 
    ResourceManager:loadIconAnimation(item.icon, GUIManager.renderer)
  local button = Button(self, item.name, icon, self.onButtonConfirm, self.buttonEnabled, 'gui_medium')
  button.item = item
  local id = item.use.skillID
  id = id >= 0 and id or defaultSkillID
  button.skill = ItemAction:fromData(id, button.item)
  self:createButtonInfo(button, itemSlot.count, 'gui_medium')
end

---------------------------------------------------------------------------------------------------
-- Input handlers
---------------------------------------------------------------------------------------------------

-- Called when player chooses an item.
-- @param(button : Button) the button selected
function ItemWindow:onButtonConfirm(button)
  local id = button.item.use.skillID
  id = id >= 0 and id or defaultSkillID
  self:selectAction(button.skill)
  if self.result and self.result.executed and button.item.use.consume then
    self.inventory:removeItem(button.item.id)
  end
end
-- Tells if an item can be used.
-- @param(button : Button) the button to check
-- @ret(boolean)
function ItemAction:buttonEnabled(button)
  return button.skill:canExecute(TurnManager:currentCharacter())
end
-- Called when player cancels.
function ItemWindow:onCancel()
  self:changeWindow(self.GUI.turnWindow)
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- New button width.
function ItemWindow:buttonWidth()
  return 144
end
-- New col count.
function ItemWindow:colCount()
  return 2
end
-- New row count.
function ItemWindow:rowCount()
  return 7
end
-- String identifier.
function ItemWindow:__tostring()
  return 'ItemWindow'
end

return ItemWindow
