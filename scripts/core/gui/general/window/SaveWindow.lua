
--[[===============================================================================================

SaveWindow
---------------------------------------------------------------------------------------------------
Window that shows the list of save slots.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')
local ConfirmWindow = require('core/gui/general/window/ConfirmWindow')

local SaveWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function SaveWindow:init(...)
  GridWindow.init(self, ...)
  self.confirmWindow = ConfirmWindow(self.GUI)
  self.confirmWindow:setXYZ(0, 0, -50)
  self.confirmWindow:setVisible(false)
end
-- Overrides GridWindow:createWidgets.
function SaveWindow:createWidgets()
  for i = 1, SaveManager.maxSaves do
    self:createSaveButton(i .. '', Vocab.saveName .. ' ' .. i)
  end
end
-- Creates a button for the given save file.
-- @param(file : string) Name of the file (without .save extension).
-- @param(name : string) Name of the button that will be shown.
-- @ret(Button) Newly created button.
function SaveWindow:createSaveButton(file, name)
  local save = SaveManager.saves[file]
  local button = Button(self)
  button.file = file
  button.save = save
  button:createText(save and (name or file) or Vocab.noSave)
  return button
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- When player chooses a file to load.
function SaveWindow:onButtonConfirm(button)
  if button.save then
    local result = self.GUI:showWindowForResult(self.confirmWindow)
    if result == 0 then
      return
    end
  end
  button:createText(Vocab.saveName .. ' ' .. button.file)
  SaveManager:storeSave(button.file)
  self.result = button.file
end
-- When player cancels the load action.
function SaveWindow:onButtonCancel()
  self.result = ''
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function SaveWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function SaveWindow:rowCount()
  return math.min(SaveManager.maxSaves, 4)
end
-- @ret(string) String representation (for debugging).
function SaveWindow:__tostring()
  return 'Save Window'
end

return SaveWindow