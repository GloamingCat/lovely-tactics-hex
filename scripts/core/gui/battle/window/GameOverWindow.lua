
--[[===============================================================================================

GameOverWindow
---------------------------------------------------------------------------------------------------
A window that contains options after game over.
result = 1 -> continue
result = 2 -> retry
result = 3 -> title screen

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')

local GameOverWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
function GameOverWindow:createWidgets()
  Button:fromKey(self, 'continue')
  Button:fromKey(self, 'retry')
  Button:fromKey(self, 'title')
end

---------------------------------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------------------------------

function GameOverWindow:continueEnabled()
  return BattleManager.params.gameOverCondition == 0
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function GameOverWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function GameOverWindow:rowCount()
  return 3
end
-- @ret(string) String representation (for debugging).
function GameOverWindow:__tostring()
  return 'Game Over Window'
end

return GameOverWindow