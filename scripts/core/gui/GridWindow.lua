
--[[===============================================================================================

GridWindow
---------------------------------------------------------------------------------------------------
Provides the base for windows with buttons.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridScroll = require('core/gui/widget/GridScroll')
local Highlight = require('core/gui/widget/Highlight')
local List = require('core/base/datastruct/List')
local Matrix2 = require('core/math/Matrix2')
local SimpleText = require('core/gui/widget/SimpleText')
local Sprite = require('core/graphics/Sprite')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')
local WindowCursor = require('core/gui/widget/WindowCursor')

-- Alias
local ceil = math.ceil

local GridWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides Window:createContent.
function GridWindow:createContent(width, height)
  self.matrix = Matrix2(self:colCount(), 1)
  self:createWidgets()
  self.currentCol = 1
  self.currentRow = 1
  self.offsetCol = 0
  self.offsetRow = 0
  if not self.noCursor then
    self.cursor = WindowCursor(self)
  end
  if not self.noHighlight then
    self.highlight = Highlight(self)
  end
  self.loopVertical = true
  self.loopHorizontal = true
  Window.createContent(self, width or self:calculateWidth(), height or self:calculateHeight())
  self:packWidgets()
end
-- Reposition widgets so they are aligned and inside the window and adjusts sliders.
function GridWindow:packWidgets()
  self.matrix.height = ceil(#self.matrix / self:colCount())
  if self:actualRowCount() > self:rowCount() then
    self.scroll = self.scroll or GridScroll(self, Vector(self.width / 2 - self:hPadding(), 0), 
      self.height - self:vPadding() * 2)
  elseif self.scroll then
    self.scroll:destroy()
    self.scroll = nil
  end
  self:updateViewport(self.currentCol, self.currentRow)
  if self.cursor then
    self.cursor:updatePosition(self.position)
  end
  if self.highlight then
    self.highlight:updatePosition(self.position)
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Overrides Window:setActive.
-- Hides cursor and unselected button if deactivated.
function GridWindow:setActive(value)
  if self.active ~= value then
    self.active = value
    local button = self:currentButton()
    if value then
      if button then
        button:setSelected(true)
        if button.onSelect then
          button.onSelect(self, button)
        end
      end
      if self.cursor and self.open then
        self.cursor:show()
      end
      if self.highlight and self.open then
        self.highlight:show()
      end
    else
      if self.cursor then
        self.cursor:hide()
      end
      if not (button and button.selected) then
        if self.highlight then
          self.highlight:hide()
        end
      end
    end
  end
end
-- Overrides Window:showContent.
-- Checks if there is a selected button to show/hide the cursor.
function GridWindow:showContent()
  Window.showContent(self)
  local button = self:currentButton()
  if button and button.selected then
    if button.onSelect then
      button.onSelect(self, button)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------------------------------

-- Adds the grid widgets of the window.
function GridWindow:createWidgets()
  -- Abstract.
end
-- Getscurrent selected button.
-- @ret(Button) the selected button
function GridWindow:currentButton()
  return self.matrix:get(self.currentCol, self.currentRow)
end
-- Gets the number of buttons.
-- @ret(number)
function GridWindow:buttonCount()
  return #self.matrix
end
-- Insert button at the given index.
-- @param(button : Button) the button to insert
-- @param(pos : number) the index of the button (optional, last position by default)
function GridWindow:insertButton(button, pos)
  pos = pos or #self.matrix + 1
  local last = #self.matrix
  assert(pos >= 1 and pos <= last + 1, 'invalid button index: ' .. pos)
  for i = last + 1, pos + 1, -1 do
    self.matrix[i] = self.matrix[i - 1]
    self.matrix[i]:setIndex(i)
    self.matrix[i]:updatePosition(self.position)
  end
  self.matrix[pos] = button
  button:setIndex(pos)
  button:updatePosition(self.position)
end
-- Removes button at the given index.
-- @param(pos : number) the index of the button
-- @ret(Button) the removed button
function GridWindow:removeButton(pos)
  local last = #self.matrix
  assert(pos >= 1 and pos <= last, 'invalid button index: ' .. pos)
  local button = self.matrix[pos]
  button:destroy()
  for i = pos, last - 1 do
    self.matrix[i] = self.matrix[i+1]
    self.matrix[i]:setIndex(i)
    self.matrix[i]:updatePosition(self.position)
  end
  self.matrix[last] = nil
  return button
end
-- Removes all buttons.
function GridWindow:clearWidgets()
  local last = #self.matrix
  for i = 1, last do
    self.matrix[i]:destroy()
    self.matrix[i] = nil
  end
end
-- Sets the current selected button.
-- @param(button : Button) nil to unselected all buttons
function GridWindow:setSelectedButton(button)
  if button then
    button:setSelected(true)
    if self.cursor then
      self.cursor:updatePosition(self.position)
      self.cursor:show()
    end
    if self.highlight then
      self.highlight:updatePosition(self.position)
      self.highlight:show()
    end
  else
    button = self:currentButton()
    if button then
      button:setSelected(false)
    end
    if self.cursor then
      self.cursor:hide()
    end
    if self.highlight then
      self.highlight:hide()
    end
  end
end
-- Gets the cell shown in the given position.
-- @ret(Widget)
function GridWindow:getCell(x, y)
  if x < 1 or x > self:colCount() or y < 1 or y > self:rowCount() then
    return nil
  end
  return self.matrix:get(self.offsetCol + x, self.offsetRow + y)
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- Called when player confirms.
function GridWindow:onConfirm()
  local button = self:currentButton()
  if button.enabled then
    if button.confirmSound then
      AudioManager:playSFX(button.confirmSound)
    end
    button.onConfirm(self, button)
  else
    if button.errorSound then
      AudioManager:playSFX(button.errorSound)
    end
  end
end
-- Called when player cancels.
function GridWindow:onCancel()
  local button = self:currentButton()
  if button.cancelSound then
    AudioManager:playSFX(button.cancelSound)
  end
  button.onCancel(self, button)
end
-- Called when player moves cursor.
function GridWindow:onMove(dx, dy)
  self:nextButton(dx, dy)
end
-- Called when plauer moves the mouse.
function GridWindow:onMouseMove(x, y)
  if self:isInside(x, y) then
    if self.scroll then
      self.scroll:onMouseMove(x, y)
    end
    x, y = x + self.width / 2 - self:hPadding(), y + self.height / 2 - self:vPadding()
    x, y = math.floor(x / self:cellWidth()) + 1, math.floor(y / self:cellHeight()) + 1
    local button = self:getCell(x, y)
    if button then
      self.currentCol = x + self.offsetCol
      self.currentRow = y + self.offsetRow
      self:setSelectedButton(button)
    end
  end
end

function GridWindow:nextButton(dx, dy)
  local c, r = self:movedCoordinates(self.currentCol, self.currentRow, dx, dy)
  local oldButton = self:currentButton()
  self.currentCol = c
  self.currentRow = r
  local newButton = self:currentButton()
  if oldButton ~= newButton then 
    if newButton.selectSound then
      AudioManager:playSFX(newButton.selectSound)
    end
    oldButton:setSelected(false)
    newButton:setSelected(true)
  end
  if oldButton.onMove then
    oldButton.onMove(self, oldButton, dx, dy)
  end
  if newButton.onSelect then
    newButton.onSelect(self, newButton)
  end
  self:updateViewport(c, r)
  if self.cursor then
    self.cursor:updatePosition(self.position)
  end
  if self.highlight then
    self.highlight:updatePosition(self.position)
  end
end

---------------------------------------------------------------------------------------------------
-- Coordinate change
---------------------------------------------------------------------------------------------------

-- Gets the coordinates adjusted depending on loop types.
-- @param(c : number) the column number
-- @param(r : number) the row number
-- @param(dx : number) the direction in x
-- @param(dy : number) the direction in y
-- @ret(number) new column number
-- @ret(number) new row number
-- @ret(boolean) true if visible buttons changed
function GridWindow:movedCoordinates(c, r, dx, dy)
  local button = self.matrix:get(c + dx, r + dy)
  if button then
    return c + dx, r + dy
  end
  if dx ~= 0 then
    if self.loopHorizontal then
      if dx > 0 then
        c = self:rightLoop(r)
      else
        c = self:leftLoop(r)
      end
    end
  else
    if self.loopVertical then
      if dy > 0 then
        r = self:upLoop(c)
      else
        r = self:downLoop(c)
      end
    end
  end
  return c, r
end
-- Loops row r to the right.
function GridWindow:rightLoop(r)
  local c = 1
  while not self.matrix:get(c,r) do
    c = c + 1
  end
  return c
end
-- Loops row r to the left.
function GridWindow:leftLoop(r)
  local c = self.matrix.width
  while not self.matrix:get(c,r) do
    c = c - 1
  end
  return c
end
-- Loops column c up.
function GridWindow:upLoop(c)
  local r = 1
  while not self.matrix:get(c,r) do
    r = r + 1
  end
  return r
end
-- Loops column c down.
function GridWindow:downLoop(c)
  local r = self.matrix.height
  while not self.matrix:get(c,r) do
    r = r - 1
  end
  return r
end

---------------------------------------------------------------------------------------------------
-- Viewport
---------------------------------------------------------------------------------------------------

-- Adapts the visible buttons.
-- @param(c : number) the current button's column
-- @param(r : number) the current button's row
function GridWindow:updateViewport(c, r)
  local newOffsetCol, newOffsetRow = self:newViewport(c, r)
  if newOffsetCol ~= self.offsetCol or newOffsetRow ~= self.offsetRow then
    self.offsetCol = newOffsetCol
    self.offsetRow = newOffsetRow
    for button in self.matrix:iterator() do
      button:hide()
      button:updatePosition(self.position)
      button:show()
    end
    if self.scroll then
      self.scroll:updatePosition(self.position)
    end
  end
end
-- Determines the new (c, r) coordinates of the button matrix viewport.
-- @param(newc : number) the selected button's column
-- @param(newr : number) the selected button's row
function GridWindow:newViewport(newc, newr)
  local c, r = self.offsetCol, self.offsetRow
  if newc < c + 1 then
    c = newc - 1
  elseif newc > c + self:colCount() then
    c = newc - self:colCount()
  end
  if newr < r + 1 then
    r = newr - 1
  elseif newr > r + self:rowCount() then
    r = newr - self:rowCount()
  end
  return c, r
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Columns of the button matrix.
-- @ret(number) the number of visible columns
function GridWindow:colCount()
  return 3
end
-- Rows of the button matrix.
-- @ret(number) the number of visible lines
function GridWindow:rowCount()
  return 4
end
-- Gets the number of rows that where actually occupied by buttons.
-- @ret(number) row count
function GridWindow:actualRowCount()
  return self.matrix.height
end
-- Grid X-axis displacement.
-- @ret(number) displacement in pixels
function GridWindow:gridX()
  return 0
end
-- Grid X-axis displacement.
-- @ret(number) displacement in pixels
function GridWindow:gridY()
  return 0
end
-- Gets the total width of the window.
-- @ret(number) the window's width in pixels
function GridWindow:calculateWidth()
  local cols = self:colCount()
  local buttons = cols * self:cellWidth() + (cols - 1) * self:colMargin()
  return self:hPadding() * 2 + buttons + self:gridX()
end
-- Gets the total height of the window.
-- @ret(number) the window's height in pixels
function GridWindow:calculateHeight()
  local rows = self:rowCount()
  local buttons = rows * self:cellHeight() + (rows - 1) * self:rowMargin()
  return self:vPadding() * 2 + buttons + self:gridY()
end
-- Gets the width of a single cell.
-- @ret(number) the width in pixels
function GridWindow:cellWidth()
  return 70
end
-- Gets the height of a single cell.
-- @ret(number) the height in pixels
function GridWindow:cellHeight()
  return 12
end
-- Gets the space between columns.
-- @ret(number) the space in pixels
function GridWindow:colMargin()
  return 6
end
-- Gets the space between rows.
-- @ret(number) the space in pixels
function GridWindow:rowMargin()
  return 2
end

return GridWindow