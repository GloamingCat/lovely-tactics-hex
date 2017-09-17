
--[[===============================================================================================

IndividualItems
---------------------------------------------------------------------------------------------------
Creates a separate inventory for each character.

=================================================================================================]]

-- Imports
local BattlerBase = require('core/battle/BattlerBase')
local Inventory = require('core/battle/Inventory')
local BattleGUI = require('core/gui/battle/BattleGUI')
local TurnWindow = require('core/gui/battle/window/TurnWindow')
local ItemWindow = require('core/gui/battle/window/ItemWindow')
local Button = require('core/gui/Button')
local TradeSkill = require('custom/plugins/IndividualItems/TradeSkill')

-- Parameters
local skillID = args.skillID
local weightName = args.attName

---------------------------------------------------------------------------------------------------
-- BattleGUI
---------------------------------------------------------------------------------------------------

-- Get items from character's inventory.
function BattleGUI:createItemWindow()
  local character = TurnManager:currentCharacter()
  local inventory = character.battler.inventory
  local itemList = inventory:getUsableItems(1)
  print(#itemList, #inventory)
  if #itemList > 0 then
    self.itemWindow = ItemWindow(self, inventory, itemList)
  end
end

---------------------------------------------------------------------------------------------------
-- TurnWindow
---------------------------------------------------------------------------------------------------

-- Add "Trade" button and reorder buttons.
function TurnWindow:createButtons()
  self.tradeSkill = TradeSkill(skillID)
  Button(self, Vocab.attack, nil, self.onAttackAction, self.attackEnabled)
  Button(self, Vocab.move, nil, self.onMoveAction, self.moveEnabled)
  Button(self, Vocab.skill, nil, self.onSkill, self.skillEnabled)
  Button(self, Vocab.item, nil, self.onItem, self.itemEnabled)
  Button(self, Vocab.trade, nil, self.onTradeAction, self.tradeEnabled)
  Button(self, Vocab.escape, nil, self.onEscapeAction, self.escapeEnabled)
  Button(self, Vocab.wait, nil, self.onWait)
  Button(self, Vocab.callAlly, nil, self.onCallAllyAction, self.callAllyEnabled)
end
-- "Trade" button callback.
function TurnWindow:onTradeAction(button)
  self:selectAction(self.tradeSkill)
end
-- Trade condition. Enabled if there are any characters nearby that have items.
function TurnWindow:tradeEnabled(button)
  return self:skillActionEnabled(button, self.tradeSkill)
end

---------------------------------------------------------------------------------------------------
-- BattleBase
---------------------------------------------------------------------------------------------------

-- Store inventory in save data.
local BattlerBase_createPersistentData = BattlerBase.createPersistentData
function BattlerBase:createPersistentData()
  local data = BattlerBase_createPersistentData(self)
  data.items = self.inventory:getState()
  return data
end
-- Add weight attribute.
local BattlerBase_createAttributes = BattlerBase.createAttributes
function BattlerBase:createAttributes()
  BattlerBase_createAttributes(self)
  self.maxWeight = self.att[weightName]
end

---------------------------------------------------------------------------------------------------
-- BattleBase
---------------------------------------------------------------------------------------------------

-- Gets the weight sum of all items.
-- @ret(number)
function Inventory:getTotalWeight()
  local sum = 0
  for i = 1, self.size do
    local item = Database.items[self[i].id]
    sum = sum + (item.tags.weight or 0) * self[i].count
  end
  return sum
end
