
--[[===============================================================================================

LoadWindow
---------------------------------------------------------------------------------------------------
Window that shows the list of save files to load.

=================================================================================================]]

-- Imports
local SaveWindow = require('core/gui/general/window/SaveWindow')

local LoadWindow = class(SaveWindow)

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- When player chooses a file to load.
function LoadWindow:onButtonConfirm(button)
  self.result = button.file
end
-- When player cancels the load action.
function LoadWindow:onButtonCancel()
  self.result = ''
end
function LoadWindow:buttonEnabled(button)
  return button.save ~= nil
end
-- @ret(string) String representation (for debugging).
function LoadWindow:__tostring()
  return 'Load Window'
end

return LoadWindow