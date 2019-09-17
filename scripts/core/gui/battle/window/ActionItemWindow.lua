
--[[===============================================================================================

ActionItemWindow
---------------------------------------------------------------------------------------------------
The GUI that is open to choose an item from character's inventory.

=================================================================================================]]

-- Imports
local ActionWindow = require('core/gui/battle/window/ActionWindow')
local Button = require('core/gui/widget/control/Button')
local InventoryWindow = require('core/gui/general/window/InventoryWindow')
local ItemAction = require('core/battle/action/ItemAction')
local Vector = require('core/math/Vector')

local ActionItemWindow = class(ActionWindow, InventoryWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Creates a button from an item ID.
-- @param(id : number) the item ID
function ActionItemWindow:createListButton(itemSlot)
  local button = InventoryWindow.createListButton(self, itemSlot)
  button.skill = ItemAction:fromData(button.item.skillID, button.item)
end

---------------------------------------------------------------------------------------------------
-- Input handlers
---------------------------------------------------------------------------------------------------

-- Called when player chooses an item.
-- @param(button : Button) the button selected
function ActionItemWindow:onButtonConfirm(button)
  self:selectAction(button.skill)
end
-- Called when player cancels.
function ActionItemWindow:onButtonCancel(button)
  self.GUI:hideDescriptionWindow()
  self:changeWindow(self.GUI.turnWindow)
end
-- Tells if an item can be used.
-- @param(button : Button) the button to check
-- @ret(boolean)
function ActionItemWindow:buttonEnabled(button)
  local user = TurnManager:currentCharacter()
  return button.skill:canBattleUse(user) and self:skillActionEnabled(button.skill)
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- String identifier.
function ActionItemWindow:__tostring()
  return 'Item Window'
end

return ActionItemWindow
