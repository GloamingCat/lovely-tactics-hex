
--[[===============================================================================================

KeyMapWindow
---------------------------------------------------------------------------------------------------
Window with resolution options.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')

-- Constants
local keys = { 'confirm', 'cancel', 'dash', 'pause', 'prev', 'next' }

local KeyMapWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Implements GridWindow:createWidgets.
function KeyMapWindow:createWidgets()
  self.map = util.table.deepCopy(SaveManager.current.config.keyMap or KeyMap)
  for i = 1, #keys do
    self:createKeyButtons(keys[i])
  end
end
-- Creates main and alt buttons for the given key.
-- @param(key : string) Key type code.
function KeyMapWindow:createKeyButtons(key)
  local button1 = Button(self)
  button1:createText((Vocab[key] or key))
  button1:createInfoText(self.map.main[key])
  button1.key = key
  button1.map = self.map.main
  local button2 = Button(self)
  button2:createText((Vocab[key] or key) .. ' (' .. Vocab.alt .. ')')
  button2:createInfoText(self.map.alt[key])
  button2.key = key
  button2.map = self.map.alt
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- Chooses new resolution.
function KeyMapWindow:onButtonConfirm(button)
  
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function KeyMapWindow:colCount()
  return 2
end
-- Overrides GridWindow:rowCount.
function KeyMapWindow:rowCount()
  return 6
end
-- Overrides GridWindow:cellWidth()
function KeyMapWindow:cellWidth()
  return 140
end
-- @ret(string) String representation (for debugging).
function KeyMapWindow:__tostring()
  return 'Resolution Window'
end

return KeyMapWindow