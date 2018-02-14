
--[[===============================================================================================

TargetWindow
---------------------------------------------------------------------------------------------------
Window that shows when the battle cursor is over a character.

=================================================================================================]]

-- Imports
local Gauge = require('core/gui/general/widget/Gauge')
local IconList = require('core/gui/general/widget/IconList')
local SimpleText = require('core/gui/widget/SimpleText')
local Sprite = require('core/graphics/Sprite')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')

-- Constants
local hpKey = Config.battle.attHP
local spKey = Config.battle.attSP
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
  local posName = Vector(x, y - 1)
  self.textName = SimpleText('', posName, w, 'center')
  self.content:add(self.textName)
  -- Class text
  local posClass = Vector(x, y + 15)
  self.textClass = SimpleText('', posClass, w, 'right', font)
  self.content:add(self.textClass)
  -- Level text
  self.textLevel = SimpleText('', posClass, w, 'left', font)
  self.content:add(self.textLevel)
  -- State values texts
  local posHP = Vector(x, y + 25)
  self.gaugeHP = self:addStateVariable(Vocab.hp, posHP, w, Color.barHP)
  local posSP = Vector(x, y + 35)
  self.gaugeSP = self:addStateVariable(Vocab.sp, posSP, w, Color.barSP)
  -- Icon List
  local posIcons = Vector(x + 8, y + 55)
  self.iconList = IconList(posIcons, w, 16)
  self.content:add(self.iconList)
  collectgarbage('collect')
end
-- Creates texts for the given state variable.
-- @param(name : string) the name of the variable
-- @param(pos : Vector) the position of the text
-- @param(w : width) the max width of the text
function TargetWindow:addStateVariable(name, pos, w, barColor)
  local textName = SimpleText(name, pos, w, 'left', Fonts.gui_small)
  self.content:add(textName)
  local gauge = Gauge(pos, w, barColor, 30)
  self.content:add(gauge)
  return gauge
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
  -- Class text
  self.textClass:setText(battler.class.data.name)
  self.textClass:redraw()
  -- Level text
  self.textLevel:setText(Vocab.level .. ' ' .. battler.class.level)
  self.textLevel:redraw()
  -- HP Gauge
  self.gaugeHP:setValues(battler.state.hp, battler.mhp())
  -- SP Gauge
  self.gaugeSP:setValues(battler.state.sp, battler.msp())
  -- Status icons
  self.iconList:setIcons(icons)
  self.iconList:updatePosition(self.position)
  if not self.open then
    self.iconList:hide()
  end
  collectgarbage('collect')
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Calculates the height given the shown variables.
function TargetWindow:calculateHeight(showStatus)
  -- Margin + name + Class/level + HP + SP
  local h = self:vPadding() * 2 + 15 + 10 + 10 + 10
  return showStatus and h + 16 or h
end
-- String representation.
function TargetWindow:__tostring()
  return 'Battle Target Window'
end

return TargetWindow
