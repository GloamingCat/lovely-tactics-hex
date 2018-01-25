
--[[===============================================================================================

TargetWindow
---------------------------------------------------------------------------------------------------
Window that shows when the battle cursor is over a character.

=================================================================================================]]

-- Imports
local IconList = require('core/gui/general/widget/IconList')
local SimpleText = require('core/gui/widget/SimpleText')
local Sprite = require('core/graphics/Sprite')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')

-- Constants
local hpName = Config.battle.attHP
local spName = Config.battle.attSP
local font = Fonts.gui_small

local TargetWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides Window:init.
function TargetWindow:init(GUI)
  local w = 120
  local h = self:calculateHeight()
  local margin = GUI:windowMargin()
  Window.init(self, GUI, w, h, Vector(ScreenManager.width / 2 - w / 2 - margin, 
      -ScreenManager.height / 2 + h / 2 + margin))
end
-- Initializes name and status texts.
function TargetWindow:createContent(width, height)
  Window.createContent(self, width, height)
  -- Top-left position
  local x = -self.width / 2 + self:hPadding()
  local y = -self.height / 2 + self:vPadding()
  local w = self.width - self:hPadding() * 2
  -- Name text
  local posName = Vector(x, y)
  self.textName = SimpleText('', posName, w, 'center')
  self.content:add(self.textName)
  -- State values texts
  local posHP = Vector(x, y + 15)
  self.textHP = self:addStateVariable(Config.attributes[hpName].shortName, posHP, w)
  local posSP = Vector(x, y + 25)
  self.textSP = self:addStateVariable(Config.attributes[spName].shortName, posSP, w)
  -- Icon List
  local posIcons = Vector(x + 8, y + 45)
  self.iconList = IconList(posIcons, w, 16)
  self.content:add(self.iconList)
  collectgarbage('collect')
end
-- Creates texts for the given state variable.
-- @param(name : string) the name of the variable
-- @param(pos : Vector) the position of the text
-- @param(w : width) the max width of the text
function TargetWindow:addStateVariable(name, pos, w)
  local textName = SimpleText(name .. ':', pos, w, 'left', font)
  local textValue = SimpleText('', pos, w, 'right', font)
  self.content:add(textName)
  self.content:add(textValue)
  return textValue
end

---------------------------------------------------------------------------------------------------
-- Content
---------------------------------------------------------------------------------------------------

-- Changes the window's content to show the given battler's stats.
-- @param(battler : Battler)
function TargetWindow:setBattler(battler)
  local icons = battler.statusList:getIcons()
  local height = self:calculateHeight(#icons > 0)
  local pos = self.spriteGrid.position
  pos.y = pos.y + (height - self.height) / 2
  self:resize(nil, height)
  -- Name text
  self.textName:setText(battler.name)
  self.textName:redraw()
  -- HP text
  local textHP = battler.state[hpName] .. '/' .. battler.att[hpName]()
  self.textHP:setText(textHP)
  self.textHP:redraw()
  -- SP text
  local textSP = battler.state[spName] .. '/' .. battler.att[spName]()
  self.textSP:setText(textSP)
  self.textSP:redraw()
  -- Status icons
  self.iconList:setIcons(icons)
  self.iconList:updatePosition(self.position)
  collectgarbage('collect')
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Calculates the height given the shown variables.
function TargetWindow:calculateHeight(showStatus)
  -- Margin + name + HP + SP
  local h = self:vPadding() * 2 + 15 + 10 + 10
  return showStatus and h + 16 or h
end
-- String representation.
function TargetWindow:__tostring()
  return 'TargetWindow'
end

return TargetWindow
