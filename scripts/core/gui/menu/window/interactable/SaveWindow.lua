
--[[===============================================================================================

SaveWindow
---------------------------------------------------------------------------------------------------
Window that shows the list of save slots.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/control/Button')
local ConfirmWindow = require('core/gui/common/window/interactable/ConfirmWindow')
local GridWindow = require('core/gui/GridWindow')
local SaveInfo = require('core/gui/widget/data/SaveInfo')

local SaveWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function SaveWindow:init(...)
  GridWindow.init(self, ...)
  self.confirmWindow = ConfirmWindow(self.GUI)
  self.confirmWindow:setXYZ(0, 0, -50)
  self.confirmWindow:setVisible(false)
  local button = self.confirmWindow.matrix[1]
  button.confirmSound = Sounds.save or button.confirmSound
  button.clickSound = button.clickSound
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
  local button = Button(self)
  button.file = file
  if not SaveManager.saves[button.file] then
    button.confirmSound = Sounds.save or button.confirmSound
    button.clickSound = button.clickSound
  end
  return button
end

---------------------------------------------------------------------------------------------------
-- Saves
---------------------------------------------------------------------------------------------------

-- Refresh each member info.
function SaveWindow:refreshSave(button)  
  if button.saveInfo then
    button.saveInfo:destroy()
    button.content:removeElement(button.saveInfo)
  end
  local w, h = self:cellWidth(), self:cellHeight()
  button.saveInfo = SaveInfo(button.file, w - self:paddingX(), h)
  button.content:add(button.saveInfo)
  button:updatePosition(self.position)
  button:refreshEnabled()
end
-- Overrides Window:show.
function SaveWindow:show(...)
  if not self.open then
    for button in self.matrix:iterator() do
      self:refreshSave(button)
    end
    self:hideContent()
  end
  GridWindow.show(self, ...)
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- When player chooses a file to load.
function SaveWindow:onButtonConfirm(button)
  if SaveManager.saves[button.file] then
    local result = self.GUI:showWindowForResult(self.confirmWindow)
    if result == 0 then
      return
    end
  end
  self:refreshSave(button)
  FieldManager:storeFieldData()
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
-- Overrides ListWindow:cellWidth.
function SaveWindow:cellWidth()
  return GridWindow.cellWidth(self) + 100
end
-- Overrides GridWindow:cellHeight.
function SaveWindow:cellHeight()
  return (GridWindow.cellHeight(self) * 3 + self:rowMargin() * 2) - 4
end
-- @ret(string) String representation (for debugging).
function SaveWindow:__tostring()
  return 'Save Window'
end

return SaveWindow
