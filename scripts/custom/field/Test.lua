
--[[===============================================================================================

Test script
---------------------------------------------------------------------------------------------------
An example of usage of an eventsheet for a Field.

=================================================================================================]]

local function testBattle()
  local party, result = FieldManager:loadBattle(1)
  if BattleManager:playerWon() then
    print 'You won!'
  elseif BattleManager:enemyWon() then
    print 'You lost...'
  elseif BattleManager:drawed() then
    print 'Draw.'
  elseif BattleManager:playerEscaped() then
    print 'You escaped!'
  elseif BattleManager:enemyEscaped() then
    print 'The enemy escaped...'
  end
end

return function(param, event, ...)
  testBattle()
  --local tile = FieldManager.currentField:getObjectTile(4, 4, 0)
  --FieldManager.player:moveToTile(tile)
end
