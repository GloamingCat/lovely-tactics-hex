
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
local Button = require('core/gui/widget/Button')

-- Constants
local defaultSkillID = Config.battle.itemSkillID

local ItemWindow = class(ActionWindow, ListButtonWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function ItemWindow:init(GUI, inventory, itemList)
  self.inventory = inventory
  local m = GUI:windowMargin()
  local w = ScreenManager.width - GUI:windowMargin() * 2
  local h = ScreenManager.height * 4 / 5 - self:vPadding() * 2 - m * 3
  self.fitRowCount = math.floor(h / self:buttonHeight())
  local fith = self.fitRowCount * self:buttonHeight() + self:vPadding() * 2
  local pos = Vector(0, fith / 2 - ScreenManager.height / 2 + m / 2, 0)
  ListButtonWindow.init(self, itemList, GUI, w, h, pos)
end
-- Creates a button from an item ID.
-- @param(id : number) the item ID
function ItemWindow:createListButton(itemSlot)
  local item = Database.items[itemSlot.id]
  local icon = item.icon.id >= 0 and 
    ResourceManager:loadIconAnimation(item.icon, GUIManager.renderer)
  local button = Button(self, self.onButtonConfirm, self.onButtonSelect, self.buttonEnabled)
  button:createText(item.name, 'gui_medium')
  button:createIcon(icon)
  button.item = item
  button.description = item.description
  local id = item.use.skillID
  id = id >= 0 and id or defaultSkillID
  button.skill = ItemAction:fromData(id, button.item)
  button:createInfoText(itemSlot.count, 'gui_medium')
end

---------------------------------------------------------------------------------------------------
-- Input handlers
---------------------------------------------------------------------------------------------------

-- Updates description when button is selected.
function ItemWindow:onButtonSelect(button)
  self.GUI.descriptionWindow:setText(button.description)
end
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

-- New button width.
function ItemWindow:buttonWidth()
  return (self.width - self:hPadding() * 2 - self:hButtonMargin()) / 2
end
-- New col count.
function ItemWindow:colCount()
  return 2
end
-- New row count.
function ItemWindow:rowCount()
  return self.fitRowCount
end
-- String identifier.
function ItemWindow:__tostring()
  return 'ItemWindow'
end

return ItemWindow
