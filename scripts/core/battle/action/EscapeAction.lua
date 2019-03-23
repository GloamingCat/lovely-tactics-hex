
--[[===============================================================================================

EscapeAction
---------------------------------------------------------------------------------------------------
The BattleAction that is executed when players chooses the "Escape" button.

=================================================================================================]]

-- Imports
local BattleAction = require('core/battle/action/BattleAction')
local ConfirmGUI = require('core/gui/general/ConfirmGUI')

-- Alias
local yield = coroutine.yield
local max = math.max

local EscapeAction = class(BattleAction)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:init. Sets animation speed.
function EscapeAction:init(...)
  BattleAction.init(self, ...)
  self.animSpeed = 10
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
  while char.sprite.color.alpha > 0 do
    local a = char.sprite.color.alpha
    char.sprite:setRGBA(nil, nil, nil, max(a - self.animSpeed, 0))
    yield()
  end
  local troop = TurnManager:currentTroop()
  troop:removeMember(char)
  if TroopManager:getMemberCount(party) == 0 then
    return { executed = true, endCharacterTurn = true, escaped = true }
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
