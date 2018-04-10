
--[[===============================================================================================

ListButtonWindow
---------------------------------------------------------------------------------------------------
A Button Window that has its buttons generated automatically given a list of arbitrary elements.

=================================================================================================]]

-- Imports
local GridWindow = require('core/gui/GridWindow')

local ListButtonWindow = class(GridWindow)

----------------------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------------------

-- Overrides GridWindow:init.
function ListButtonWindow:init(list, ...)
  self.list = list
  GridWindow.init(self, ...)
end
-- Overrides GridWindow:createWidgets.
function ListButtonWindow:createWidgets()
  for i = 1, #self.list do
    self:createListButton(self.list[i])
  end
end
-- Creates a button from an element in the list.
function ListButtonWindow:createListButton(element)
  -- Abstract.
end
-- Clears and recreates buttons.
function ListButtonWindow:refreshButtons(list)
  self.list = list or self.list
  self:clearWidgets()
  self:createWidgets()
  for i = 1, #self.matrix do
    self.matrix[i]:refreshState()
  end
  if not self:currentButton() then
    local last = self.matrix[#self.matrix]
    self.currentCol = last.col
    self.currentRow = last.row
  end
  self:packWidgets()
end

----------------------------------------------------------------------------------------------------
-- Properties
----------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function ListButtonWindow:colCount()
  return 2
end
-- Larger buttons.
function ListButtonWindow:cellWidth()
  local w = ScreenManager.width - self.GUI:windowMargin() * 2
  return (w - self:hPadding() * 2 - self:colMargin()) / 2
end
-- @ret(string) String representation (for debugging).
function ListButtonWindow:__tostring()
  return 'List Button Window'
end

return ListButtonWindow