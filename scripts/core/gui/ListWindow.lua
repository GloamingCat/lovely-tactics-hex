
--[[===============================================================================================

ListWindow
---------------------------------------------------------------------------------------------------
A Button Window that has its buttons generated automatically given a list of arbitrary elements.

=================================================================================================]]

-- Imports
local GridWindow = require('core/gui/GridWindow')

local ListWindow = class(GridWindow)

----------------------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------------------

-- Overrides GridWindow:init.
function ListWindow:init(list, ...)
  self.list = list
  GridWindow.init(self, ...)
end
-- Overrides GridWindow:createWidgets.
function ListWindow:createWidgets()
  for i = 1, #self.list do
    self:createListButton(self.list[i])
  end
end
-- Creates a button from an element in the list.
function ListWindow:createListButton(element)
  -- Abstract.
end
-- Clears and recreates buttons.
function ListWindow:refreshButtons(list)
  self.list = list or self.list
  self:clearWidgets()
  self:createWidgets()
  for i = 1, #self.matrix do
    self.matrix[i]:refreshState()
  end
  if not self:currentWidget() then
    self.currentCol = 1
    self.currentRow = 1
  end
  local current = self:currentWidget()
  if current then
    self:setSelectedWidget(current)
  end
  self:packWidgets()
end

----------------------------------------------------------------------------------------------------
-- Properties
----------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function ListWindow:colCount()
  return 2
end
-- Larger buttons.
function ListWindow:cellWidth()
  local w = ScreenManager.width - self.GUI:windowMargin() * 2
  return (w - self:paddingX() * 2 - self:colMargin()) / 2
end
-- @ret(string) String representation (for debugging).
function ListWindow:__tostring()
  return 'List Window'
end

return ListWindow
