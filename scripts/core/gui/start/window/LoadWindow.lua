
--[[===============================================================================================

LoadWindow
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')

local LoadWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function LoadWindow:createWidgets()
  for i = 1, SaveManager.maxSaves do
    self:createSaveButton(i .. '', Vocab.saveName .. ' ' .. i)
  end
end

function LoadWindow:createSaveButton(file, name)
  local save = SaveManager.saves[file]
  local button = Button(self)
  button.file = file
  button:createText(save and (name or file) or Vocab.noSave)
  button:setEnabled(save)
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

function LoadWindow:onButtonConfirm(button)
  self.result = button.file
end

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