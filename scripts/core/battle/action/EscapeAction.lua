
--[[===============================================================================================

EscapeAction
---------------------------------------------------------------------------------------------------
The BattleAction that is executed when players chooses the "Escape" button.

=================================================================================================]]

-- Imports
local BattleAction = require('core/battle/action/BattleAction')
local ConfirmGUI = require('core/gui/general/ConfirmGUI')

local EscapeAction = class(BattleAction)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:init. Sets animation speed.
function EscapeAction:init(...)
  BattleAction.init(self, ...)
  self.animSpeed = 2
end

---------------------------------------------------------------------------------------------------
-- Callback
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:onActionGUI.
function EscapeAction:onActionGUI(input)
  local confirm = GUIManager:showGUIForResult(ConfirmGUI())
  if confirm == 1 then
    return self:onConfirm(input)
  else
    return self:onCancel(input)
  end
end
-- Overrides FieldAction:execute. 
-- Executes the escape animation for the given character.
function EscapeAction:execute(input)
  local char = input.user
  local party = char.party
  if Sounds.escape then
    AudioManager:playSFX(Sounds.escape)
  end
  char:colorizeTo(nil, nil, nil, 0, self.animSpeed, true)
  local troop = TurnManager:currentTroop()
  local member = troop:removeMember(char.key)
  TroopManager:deleteCharacter(char)
  if TroopManager:getMemberCount(party) == 0 then
    return { executed = true, endTurn = true, escaped = true }
  else
    return { executed = true, endCharacterTurn = true, escaped = false }
  end
end
-- Overrides FieldAction:canExecute.
function EscapeAction:canExecute(input)
  local userParty = input.user.party
  local tileParty = input.user:getTile().party
  return userParty == tileParty
end

return EscapeAction
