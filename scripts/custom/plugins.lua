
--[[===============================================================================================

Insert in the plugins list the plugin names to be loaded and their arguments.
Example:
  { 'plugin1', on = true, 
  a = 10, b = 'hello' }

=================================================================================================]]

local killCheat = { 'KillCheat', on = true,
  key = 'k' }
local individualTurn = { 'IndividualTurn', on = true,
  attName = 'agi',
  turnLimit = 2000 }
local individualItems = { 'IndividualItems', on = false,
  attName = 'car',
  skillID = 1 }
local controlZone = { 'ControlZone', on = false }
local removeStatusOnDamage = { 'RemoveStatusOnDamage', on = true }
local statusBalloon = { 'StatusBalloon', on = true }

---------------------------------------------------------------------------------------------------
-- Plugin list
---------------------------------------------------------------------------------------------------

return { 
  killCheat, 
  individualTurn, 
  controlZone, 
  statusBalloon, 
  removeStatusOnDamage,
  individualItems }

