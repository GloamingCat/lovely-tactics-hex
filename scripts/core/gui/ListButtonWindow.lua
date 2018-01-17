
--[[===============================================================================================

ListButtonWindow
---------------------------------------------------------------------------------------------------
A Button Window that has its buttons generated automatically given a list of
arbitrary elements.

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
  if #self.list > 0 then
    for i = 1, #self.list do
      self:createListButton(self.list[i])
    end
  end
end
-- Creates a button from an element in the list.
function ListButtonWindow:createListButton(element)
  -- Abstract.
end

function ListButtonWindow:overrideButtons(list)
  self.list = list
  self:clearButtons()
  self:createWidgets()
end

return ListButtonWindow

