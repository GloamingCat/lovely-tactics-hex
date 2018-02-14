
--[[===============================================================================================

ChoiceWindow
---------------------------------------------------------------------------------------------------
Shows a list of custom choices.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')
local List = require('core/datastruct/List')

local ChoiceWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function ChoiceWindow:init(GUI, args)
  self.choices = List(args.choices)
  self.width = args.width
  self.align = args.align
  self.cancelChoice = args.cancel
  GridWindow.init(self, GUI, self.width, nil, args.pos)
end

function ChoiceWindow:createWidgets()
  for i = 1, self.choices.size do
    local choice = self.choices[i]
    local button = Button(self)
    button:createText(choice, 'gui_medium', self.align)
    button.choice = i
  end
end

---------------------------------------------------------------------------------------------------
-- Input Callbacks
---------------------------------------------------------------------------------------------------

function ChoiceWindow:onButtonConfirm(button)
  self.result = button.choice
end

function ChoiceWindow:onButtonCancel(button)
  self.result = self.cancelChoice
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

function ChoiceWindow:colCount()
  return 1
end

function ChoiceWindow:rowCount()
  return #self.choices
end

function ChoiceWindow:cellWidth()
  return self.width - self:hPadding() * 2
end
-- @ret(string) String representation (for debugging).
function ChoiceWindow:__tostring()
  return 'ChoiceWindow: ' .. tostring(self.choices)
end

return ChoiceWindow