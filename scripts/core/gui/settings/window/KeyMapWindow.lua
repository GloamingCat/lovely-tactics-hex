
--[[===============================================================================================

KeyMapWindow
---------------------------------------------------------------------------------------------------
Window with resolution options.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')

-- Alias
local copyTable = util.table.deepCopy

-- Constants
local keys = { 'confirm', 'cancel', 'dash', 'pause', 'prev', 'next' }

local KeyMapWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Implements GridWindow:createWidgets.
function KeyMapWindow:createWidgets()
  for i = 1, #keys do
    self:createKeyButtons(keys[i])
  end
  Button:fromKey(self, 'apply').text:setAlign('center')
  Button:fromKey(self, 'default').text:setAlign('center')
end
-- Creates main and alt buttons for the given key.
-- @param(key : string) Key type code.
function KeyMapWindow:createKeyButtons(key)
  local button1 = Button(self)
  button1:createText((Vocab[key] or key))
  button1.key = key
  button1.map = 'main'
  local button2 = Button(self)
  button2:createText((Vocab[key] or key) .. ' (' .. Vocab.alt .. ')')
  button2.key = key
  button2.map = 'alt'
end

---------------------------------------------------------------------------------------------------
-- Keys
---------------------------------------------------------------------------------------------------

-- Overrides Window:show.
function KeyMapWindow:show(...)
  if not self.open then
    self.map = copyTable(SaveManager.current.config.keyMap or KeyMap)
    self:refreshKeys()
    self:hideContent()
    GridWindow.show(self, ...)
  end
end
-- Refreshes key codes.
function KeyMapWindow:refreshKeys()
  for i = 1, #self.matrix do
    local b = self.matrix[i]
    if b.map then
      local map = self.map[b.map]
      b:createInfoText(map[b.key])
      b:updatePosition(self.position)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- Chooses new resolution.
function KeyMapWindow:onButtonConfirm(button)
  self.cursor.paused = true
  button:createInfoText('')
  repeat
    coroutine.yield()
  until InputManager.lastKey
  button:createInfoText(InputManager.lastKey)
  button:updatePosition(self.position)
  local map = self.map[button.map]
  map[button.key] = InputManager.lastKey
  self.cursor.paused = false
end
-- Applies changes.
function KeyMapWindow:applyConfirm()
  SaveManager.current.config.keyMap = copyTable(self.map)
  InputManager:setKeyMap(self.map)
end
-- Sets default key map.
function KeyMapWindow:defaultConfirm()
  self.map = copyTable(KeyMap)
  self:refreshKeys()
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
  return 7
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