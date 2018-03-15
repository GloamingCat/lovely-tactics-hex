
--[[===============================================================================================

FieldCommandWindow
---------------------------------------------------------------------------------------------------
Main GUI's selectable window.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')

local FieldCommandWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Implements GridWindow:createWidgets.
function FieldCommandWindow:createWidgets()
  Button:fromKey(self, 'members')
  Button:fromKey(self, 'config')
  Button:fromKey(self, 'save')
  Button:fromKey(self, 'quit')
end

---------------------------------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------------------------------

function FieldCommandWindow:membersConfirm()
  self:hide()
  self.GUI.membersWindow:show()
  self.GUI.membersWindow:activate()
end

function FieldCommandWindow:configConfirm()
  
end

function FieldCommandWindow:saveConfirm()
  self.GUI:showWindowForResult(self.GUI.saveWindow)
end

function FieldCommandWindow:quitConfirm()
  self.GUI:showWindowForResult(self.GUI.quitWindow)
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function FieldCommandWindow:colCount()
  return 2
end
-- Overrides GridWindow:rowCount.
function FieldCommandWindow:rowCount()
  return 2
end
-- @ret(string) String representation (for debugging).
function FieldCommandWindow:__tostring()
  return 'Field Command Window'
end

return FieldCommandWindow