
--[[===============================================================================================

SwitchButton
---------------------------------------------------------------------------------------------------

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')

local SwitchButton = class(Button)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(window  : GridWindow) the window this spinner belongs to.
-- @param(initValue : number) Initial value.
-- @param(x : number) Position x of the switch text relative to the button width (from 0 to 1).
function SwitchButton:init(window, initValue, x)
  Button.init(self, window)
  x = x or 0.3
  local w = self.window:cellWidth()
  self:initContent(initValue or false, w * x, self.window:cellHeight() / 2, w * (1 - x))
end
-- Creates a button for the action represented by the given key.
-- @param(window : GridWindow) the window that this button is component of
-- @param(key : string) action's key
-- @ret(SwitchButton)
function SwitchButton:fromKey(window, key, initValue)
  local button = self(window, initValue)
  local icon = Icons[key]
  if icon then
    button:createIcon(icon)
  end
  local text = Vocab[key]
  if text then
    button:createText(text)
  end
  button.onConfirm = window[key .. 'Confirm'] or button.onConfirm
  button.onChange = window[key .. 'Change'] or button.onChange
  button.key = key
  return button
end
function SwitchButton:initContent(initValue)
  self.value = initValue
  local text = self.value and Vocab.on or Vocab.off
  self:createInfoText(text)
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

function SwitchButton.onConfirm(window, self)
  self:changeValue(not self.value)
end

function SwitchButton.onMove(window, self, dx, dy)
  if dx ~= 0 then
    print (dx > 0)
    self:changeValue(dx > 0)
  end
end

function SwitchButton:changeValue(value)
  if self.value ~= value then
    self:setValue(value)
    if self.onChange then
      self.onChange(self.window, self)
    end
    if self.selectSound then
      AudioManager:playSFX(self.selectSound)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Value
---------------------------------------------------------------------------------------------------

-- Changes the current value.
-- @param(value : boolean) New value.
function SwitchButton:setValue(value)
  self.value = value
  self.infoText:setText(self.value and Vocab.on or Vocab.off)
  self.infoText:redraw()
end

return SwitchButton