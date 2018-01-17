
--[[===============================================================================================

MainWindow
---------------------------------------------------------------------------------------------------
Main GUI's selectable window.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')

local MainWindow = class(GridWindow)

function MainWindow:createWidgets()
  Button:fromKey(self, 'members')
  Button:fromKey(self, 'formation')
  Button:fromKey(self, 'config')
  Button:fromKey(self, 'save')
  Button:fromKey(self, 'quit')
end

---------------------------------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------------------------------

function MainWindow:membersConfirm()
  self:hide()
  self.GUI.membersWindow:show()
  self.GUI.membersWindow:activate()
end

function MainWindow:formationConfirm()
  
end

function MainWindow:configConfirm()
  
end

function MainWindow:saveConfirm()
  
end

function MainWindow:quitConfirm()
  
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

function MainWindow:colCount()
  return 1
end

function MainWindow:rowCount()
  return 5
end

return MainWindow