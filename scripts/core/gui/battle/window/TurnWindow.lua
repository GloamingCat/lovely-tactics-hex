
--[[===============================================================================================

TurnWindow
---------------------------------------------------------------------------------------------------
Window that opens in the start of a character turn.
Result = 1 means that the turn ended.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')
local ActionWindow = require('core/gui/battle/window/ActionWindow')
local BattleCursor = require('core/battle/BattleCursor')
local Button = require('core/gui/widget/Button')
local CallAction = require('core/battle/action/CallAction')
local EscapeAction = require('core/battle/action/EscapeAction')
local BattleMoveAction = require('core/battle/action/BattleMoveAction')
local VisualizeAction = require('core/battle/action/VisualizeAction')
local WaitAction = require('core/battle/action/WaitAction')

-- Alias
local mathf = math.field

-- Constants
local maxMembers = Config.troop.maxMembers

local TurnWindow = class(ActionWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

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
  self.backupBattlers = troop.backup
  self.currentBattlers = troop:currentCharacters(true)
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
  return self:skillActionEnabled(button, user.battler.attackSkill)
end
-- Move condition. Enabled if there are any tiles for the character to move to.
function TurnWindow:moveEnabled(button)
  local user = TurnManager:currentCharacter()
  if user.steps <= 0 then
    return false
  end
  for path in TurnManager:pathMatrix():iterator() do
    if path and path.totalCost <= user.steps then
      return true
    end
  end
  return false
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
  return TroopManager:getMemberCount() < maxMembers and not self.backupBattlers:isEmpty()
end
-- Checks if a given skill action is enabled to use.
function TurnWindow:skillActionEnabled(button, skill)
  local field = FieldManager.currentField
  local user = TurnManager:currentCharacter()
  local input = ActionInput(skill, user)
  if self:moveEnabled(button) then
    for tile in field:gridIterator() do
      if skill:isSelectable(input, tile) then
        return true
      end
    end
  else
    local range = skill.data.range
    local tile = user:getTile()
    local h = tile.layer.height
    for i, j in mathf.radiusIterator(range, tile.x, tile.y, field.sizeX, field.sizeY) do
      local t = field:getObjectTile(i, j, h)
      if skill:isSelectable(input, t) then
        return true
      end
    end
  end
  return false
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
-- Overrides Window:show.
function TurnWindow:show(add)
  local user = TurnManager:currentCharacter()
  self.userCursor:setCharacter(user)
  ActionWindow.show(self, add)
end
-- String identifier.
function TurnWindow:__tostring()
  return 'Battle Turn Window'
end

return TurnWindow
