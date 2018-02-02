
--[[===============================================================================================

ItemWindow
---------------------------------------------------------------------------------------------------
The GUI that is open to choose an item from character's inventory.

=================================================================================================]]

-- Imports
local InventoryWindow = require('core/gui/general/window/InventoryWindow')
local ActionWindow = require('core/gui/battle/window/ActionWindow')
local ItemAction = require('core/battle/action/ItemAction')
local Vector = require('core/math/Vector')
local Button = require('core/gui/widget/Button')

-- Constants
local defaultSkillID = Config.battle.itemSkillID

local ItemWindow = class(ActionWindow, InventoryWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Creates a button from an item ID.
-- @param(id : number) the item ID
function ItemWindow:createListButton(itemSlot)
  local button = InventoryWindow.createListButton(self, itemSlot)
  local id = button.item.use.skillID
  id = id >= 0 and id or defaultSkillID
  button.skill = ItemAction:fromData(id, button.item)
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
  self.GUI:hideDescriptionWindow()
  self:changeWindow(self.GUI.turnWindow)
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- String identifier.
function ItemWindow:__tostring()
  return 'Item Window'
end

return ItemWindow
