
--[[===============================================================================================

General Utilities
---------------------------------------------------------------------------------------------------
Custom functions to be used anywhere in scripts.

=================================================================================================]]

local general = {}

function general.printBattleResult()
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

util.general = general
