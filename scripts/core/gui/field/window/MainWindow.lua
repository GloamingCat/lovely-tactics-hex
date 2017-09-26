
--[[===============================================================================================

MainWindow
---------------------------------------------------------------------------------------------------
Main GUI's selectable window.

=================================================================================================]]

-- Imports
local Button = require('core/gui/Button')
local GridWindow = require('core/gui/GridWindow')

local MainWindow = class(GridWindow)

function MainWindow:createButtons()
  self:createButton('items')
  self:createButton('skills')
  self:createButton('states')
  self:createButton('party')
  self:createButton('config')
  self:createButton('save')
  self:createButton('quit')
end

---------------------------------------------------------------------------------------------------
-- Character
---------------------------------------------------------------------------------------------------

function MainWindow:itemsConfirm()
  
end

function MainWindow:skillsConfirm()
  
end

function MainWindow:statesConfirm()
  
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

function MainWindow:partyConfirm()
  
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
  return 2
end

function MainWindow:rowCount()
  return 4
end

return MainWindow


