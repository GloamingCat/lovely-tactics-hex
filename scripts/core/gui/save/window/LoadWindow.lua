
--[[===============================================================================================

LoadWindow
---------------------------------------------------------------------------------------------------
Window that shows the list of save files to load.

=================================================================================================]]

-- Imports
local SaveWindow = require('core/gui/save/window/SaveWindow')

local LoadWindow = class(SaveWindow)

---------------------------------------------------------------------------------------------------
-- Button
---------------------------------------------------------------------------------------------------

-- Overrides SaveWindow:createSaveButton.
function LoadWindow:createSaveButton(file, name)
  if SaveManager.saves[file] then
    return SaveWindow.createSaveButton(self, file, name)
  end
end

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
-- Button enabled condition.
function LoadWindow:buttonEnabled(button)
  return SaveManager.saves[button.file] ~= nil
end
-- @ret(string) String representation (for debugging).
function LoadWindow:__tostring()
  return 'Load Window'
end

return LoadWindow