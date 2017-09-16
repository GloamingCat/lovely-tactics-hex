
--[[===============================================================================================

BattleGUI
---------------------------------------------------------------------------------------------------
The GUI that is openned in the start of a character turn.
Its result is the action time that the character spent.

=================================================================================================]]

-- Imports
local GUI = require('core/gui/GUI')
local TurnWindow = require('core/gui/battle/window/TurnWindow')
local SkillWindow = require('core/gui/battle/window/SkillWindow')
local ItemWindow = require('core/gui/battle/window/ItemWindow')
local Vector = require('core/math/Vector')

local BattleGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function BattleGUI:createWindows()
  self.name = 'Battle GUI'
  self:createTurnWindow()
  self:createSkillWindow()
  self:createItemWindow()
  -- Initial state
  self.windowList:add(self.turnWindow)
  self:setActiveWindow(self.turnWindow)
end
-- Creates window with main commands.
function BattleGUI:createTurnWindow()
  self.turnWindow = TurnWindow(self)
  self.turnWindow:setPosition(Vector(-ScreenManager.width / 2 + self.turnWindow.width / 2 + 8, 
      -ScreenManager.height / 2 + self.turnWindow.height / 2 + 8))
end
-- Creates window to use skill.
function BattleGUI:createSkillWindow()
  local character = TurnManager:currentCharacter()
  local skillList = character.battler.skillList
  if not skillList:isEmpty() then
    self.skillWindow = SkillWindow(self, skillList)
  end
end
-- Creates window to use item.
function BattleGUI:createItemWindow()
  local inventory = TurnManager:currentTroop().inventory
  local itemList = inventory:getUsableItems(1)
  if #itemList > 0 then
    self.itemWindow = ItemWindow(self, inventory, itemList)
  end
end

---------------------------------------------------------------------------------------------------
-- Camera focus
---------------------------------------------------------------------------------------------------

-- Overrides GUI:show.
function BattleGUI:show(...)
  FieldManager.renderer:moveToObject(TurnManager:currentCharacter())
  GUI.show(self, ...)
end

return BattleGUI
