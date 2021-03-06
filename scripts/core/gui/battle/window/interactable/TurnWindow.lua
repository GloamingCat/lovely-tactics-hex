
--[[===============================================================================================

TurnWindow
---------------------------------------------------------------------------------------------------
Window that opens in the start of a character turn.
Result = 1 means that the turn ended.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')
local ActionWindow = require('core/gui/battle/window/interactable/ActionWindow')
local BattleCursor = require('core/battle/BattleCursor')
local Button = require('core/gui/widget/control/Button')
local CallAction = require('core/battle/action/CallAction')
local EscapeAction = require('core/battle/action/EscapeAction')
local BattleMoveAction = require('core/battle/action/BattleMoveAction')
local VisualizeAction = require('core/battle/action/VisualizeAction')
local WaitAction = require('core/battle/action/WaitAction')

-- Alias
local mathf = math.field

local TurnWindow = class(ActionWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function TurnWindow:init(...)
  self.moveAction = BattleMoveAction()
  self.callAction = CallAction()
  self.escapeAction = EscapeAction()
  self.visualizeAction = VisualizeAction()
  self.waitAction = WaitAction()
  ActionWindow.init(self, ...)
end
-- Overrides GridWindow:createContent.
-- Creates character cursor and stores troop's data.
function TurnWindow:createContent(...)
  local troop = TurnManager:currentTroop()
  self.backupBattlers = troop:backupBattlers()
  self.currentBattlers = TroopManager:currentCharacters(troop.party, true)
  ActionWindow.createContent(self, ...)
  self.userCursor = BattleCursor()
  self.content:add(self.userCursor)
end
-- Overrides GridWindow:createWidgets.
function TurnWindow:createWidgets()
  Button:fromKey(self, 'attack')
  Button:fromKey(self, 'move')
  Button:fromKey(self, 'skill')
  Button:fromKey(self, 'item')
  Button:fromKey(self, 'escape')
  Button:fromKey(self, 'callAlly')
  Button:fromKey(self, 'wait')
end

---------------------------------------------------------------------------------------------------
-- Confirm callbacks
---------------------------------------------------------------------------------------------------

-- "Attack" button callback.
function TurnWindow:attackConfirm(button)
  self:selectAction(TurnManager:currentCharacter().battler.attackSkill)
end
-- "Move" button callback.
function TurnWindow:moveConfirm(button)
  self:selectAction(self.moveAction)
end
-- "Escape" button callback.
function TurnWindow:escapeConfirm(button)
  self:selectAction(self.escapeAction)
end
-- "Call Ally" button callback.
function TurnWindow:callAllyConfirm(button)
  self:selectAction(self.callAction)
end
-- "Skill" button callback. Opens Skill Window.
function TurnWindow:skillConfirm(button)
  self:changeWindow(self.GUI.skillWindow, true)
end
-- "Item" button callback. Opens Item Window.
function TurnWindow:itemConfirm(button)
  self:changeWindow(self.GUI.itemWindow, true)
end
-- "Wait" button callback. End turn.
function TurnWindow:waitConfirm(button)
  self:selectAction(self.waitAction)
end
-- Overrides GridWindow:onCancel.
function TurnWindow:onCancel()
  AudioManager:playSFX(Sounds.buttonCancel)
  self:selectAction(self.visualizeAction)
  self.result = nil
end
-- Overrides Window:onNext.
function TurnWindow:onNext()
  local count = #TurnManager.turnCharacters
  if count > 1 then
    self.result = { characterIndex = math.mod1(TurnManager.characterIndex + 1, count) }
  end
end
-- Overrides Window:onPrev.
function TurnWindow:onPrev()
  local count = #TurnManager.turnCharacters
  if count > 1 then
    self.result = { characterIndex = math.mod1(TurnManager.characterIndex - 1, count) }
  end
end

---------------------------------------------------------------------------------------------------
-- Enable Conditions
---------------------------------------------------------------------------------------------------

-- Attack condition. Enabled if there are tiles to move to or if there are any
--  enemies that the skill can reach.
function TurnWindow:attackEnabled(button)
  local user = TurnManager:currentCharacter()
  return self:skillActionEnabled(user.battler.attackSkill)
end
-- Skill condition. Enabled if character has any skills to use.
function TurnWindow:skillEnabled(button)
  return self.GUI.skillWindow ~= nil
end
-- Item condition. Enabled if character has any items to use.
function TurnWindow:itemEnabled(button)
  return self.GUI.itemWindow ~= nil
end
-- Escape condition. Only escapes if the character is in a tile of their party.
function TurnWindow:escapeEnabled()
  if not BattleManager.params.escapeEnabled and #self.currentBattlers == 1 then
    return false
  end
  local char = TurnManager:currentCharacter()
  local userParty = char.party
  local tileParty = char:getTile().party
  return userParty == tileParty
end
-- Call Ally condition. Enabled if there any any backup members.
function TurnWindow:callAllyEnabled()
  return TroopManager:getMemberCount() < Config.troop.maxMembers and 
    not self.backupBattlers:isEmpty()
end

---------------------------------------------------------------------------------------------------
-- Show / Hide
---------------------------------------------------------------------------------------------------

-- Overrides Window:show.
function TurnWindow:show(...)
  local user = TurnManager:currentCharacter()
  self.userCursor:setCharacter(user)
  ActionWindow.show(self, ...)
end

---------------------------------------------------------------------------------------------------
-- General info
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function TurnWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function TurnWindow:rowCount()
  return 7
end
-- @ret(string) String representation (for debugging).
function TurnWindow:__tostring()
  return 'Battle Turn Window'
end

return TurnWindow
