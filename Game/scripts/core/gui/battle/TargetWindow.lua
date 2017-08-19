
--[[===============================================================================================

TargetWindow
---------------------------------------------------------------------------------------------------
Window that shows when the battle cursor is over a character.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local Sprite = require('core/graphics/Sprite')
local Window = require('core/gui/Window')
local SimpleText = require('core/gui/SimpleText')

-- Constants
local battlerVariables = Database.variables.battler
local battleConfig = Config.battle
local font = Font.gui_small

local TargetWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides Window:init.
function TargetWindow:init(GUI)
  local vars = {}
  for i = 1, #battlerVariables do
    local var = battlerVariables[i]
    if var.targetGUI then
      vars[#vars + 1] = var
    end
  end
  self.vars = vars
  local w = 100
  local h = self:calculateHeight()
  local margin = 12
  Window.init(self, GUI, w, h, Vector(ScreenManager.width / 2 - w / 2 - margin, 
      -ScreenManager.height / 2 + h / 2 + margin))
end
-- Calculates the height given the shown variables.
function TargetWindow:calculateHeight()
  return self:vpadding() * 2 + 15 + #self.vars * 10
end
-- Initializes name and status texts.
function TargetWindow:createContent(width, height)
  Window.createContent(self, width, height)
  -- Top-left position
  local x = -self.width / 2 + self:hPadding()
  local y = -self.height / 2 + self:vpadding()
  local w = self.width - self:hPadding() * 2
  -- Name text
  local posName = Vector(x, y)
  self.textName = SimpleText('', posName, w, 'center')
  self.content:add(self.textName)
  -- State values texts
  self.textState = {}
  self.textStateValues = {}
  for i = 1, #self.vars do
    local var = self.vars[i]
    local pos = Vector(x, y + 5 + i * 10)
    local textName = SimpleText(var.shortName .. ':', pos, w, 'left', font)
    local textValue = SimpleText('', pos, w, 'right', font)
    self.textState[var.shortName] = textName
    self.textStateValues[var.shortName] = textValue
    self.content:add(textName)
    self.content:add(textValue)
  end
  collectgarbage('collect')
end

---------------------------------------------------------------------------------------------------
-- Content
---------------------------------------------------------------------------------------------------

-- Changes the window's content to show the given battler's stats.
-- @param(battler : Battler)
function TargetWindow:setBattler(battler)  
  -- Name text
  self.textName:setText(battler.data.name)
  self.textName:redraw()
  -- State values text
  for i = 1, #self.vars do
    local v = self.vars[i]
    local currentValue = battler.state[v.shortName]
    local maxValue = battler.stateMax[v.shortName](battler.att)
    local text = currentValue .. ''
    if maxValue then
      text = text .. '/' .. maxValue
    end
    local stateText = self.textStateValues[v.shortName]
    stateText:setText(text)
    stateText:redraw()
  end
  collectgarbage('collect')
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- String representation.
function TargetWindow:__tostring()
  return 'TargetWindow'
end

return TargetWindow
