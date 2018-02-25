
--[[===============================================================================================

LoadWindow
---------------------------------------------------------------------------------------------------
Window that shows the list of save files to load.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')

local LoadWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:createWidgets.
function LoadWindow:createWidgets()
  for i = 1, SaveManager.maxSaves do
    self:createSaveButton(i .. '', Vocab.saveName .. ' ' .. i)
  end
end
-- Creates a button for the given save file.
-- @param(file : string) Name of the file (without .save extension).
-- @param(name : string) Name of the button that will be shown.
-- @ret(Button) Newly created button.
function LoadWindow:createSaveButton(file, name)
  local save = SaveManager.saves[file]
  local button = Button(self)
  button.file = file
  button:createText(save and (name or file) or Vocab.noSave)
  button:setEnabled(save)
  return button
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

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function LoadWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function LoadWindow:rowCount()
  return math.min(SaveManager.maxSaves, 4)
end

return LoadWindow