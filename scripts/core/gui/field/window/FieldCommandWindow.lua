
--[[===============================================================================================

FieldCommandWindow
---------------------------------------------------------------------------------------------------
Main GUI's selectable window.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')
local SaveGUI = require('core/gui/save/SaveGUI')

local FieldCommandWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Implements GridWindow:createWidgets.
function FieldCommandWindow:createWidgets()
  Button:fromKey(self, 'inventory')
  Button:fromKey(self, 'members')
  Button:fromKey(self, 'config')
  Button:fromKey(self, 'save')
  Button:fromKey(self, 'quit')
end

---------------------------------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------------------------------

function FieldCommandWindow:inventoryConfirm()
  
end

function FieldCommandWindow:membersConfirm()
  self.GUI.membersWindow:activate()
end

function FieldCommandWindow:configConfirm()
  
end

function FieldCommandWindow:saveConfirm()
  self.GUI:hide()
  GUIManager:showGUIForResult(SaveGUI())
  self.GUI:show()
end

function FieldCommandWindow:quitConfirm()
  self.GUI:showWindowForResult(self.GUI.quitWindow)
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function FieldCommandWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function FieldCommandWindow:rowCount()
  return 5
end
-- @ret(string) String representation (for debugging).
function FieldCommandWindow:__tostring()
  return 'Field Command Window'
end

return FieldCommandWindow