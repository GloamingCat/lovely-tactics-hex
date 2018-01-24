
--[[===============================================================================================

Insert in the plugins list the plugin names to be loaded and their arguments.
Example:
  { 'plugin1', on = true, 
  a = 10, b = 'hello' }

=================================================================================================]]

local generalUtil = { 'GeneralUtil', on = true }
local killCheat = { 'KillCheat', on = true,
  key = 'k' }
local individualTurn = { 'IndividualTurn', on = true,
  attName = 'agi',
  turnLimit = 2000 }
local controlZone = { 'ControlZone', on = false }
local statusBalloon = { 'StatusBalloon', on = false,
  balloonID = 26 }
local battleEndRevival = { 'BattleEndRevival', on = true }

---------------------------------------------------------------------------------------------------
-- Plugin list
---------------------------------------------------------------------------------------------------

return { 
  generalUtil,
  killCheat, 
  individualTurn, 
  controlZone, 
  statusBalloon,
  battleEndRevival }
