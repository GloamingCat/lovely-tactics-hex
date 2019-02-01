--[[===============================================================================================

Battle Test
---------------------------------------------------------------------------------------------------

=================================================================================================]]

event:startBattle { fieldID = 0, fade = 5, intro = true, gameOverCondition = 1, escapeEnabled = true}

util.general.printBattleResult()

if BattleManager:playerWon() then
	event:deleteChar { key = "Enemy", permanent = true }
end

