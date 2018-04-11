
--[[===============================================================================================

ShopBonusWindow
---------------------------------------------------------------------------------------------------
A window that shows the attribute and element bonus of the equip item.

=================================================================================================]]

-- Imports
local EquipBonusWindow = require('core/gui/members/window/EquipBonusWindow')
local Pagination = require('core/gui/widget/Pagination')
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')

local ShopBonusWindow = class(EquipBonusWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides Window:createContent.
function ShopBonusWindow:createContent(...)
  EquipBonusWindow.createContent(self, ...)
  local x = self:hPadding() - self.width / 2
  local y = self:vPadding() - self.height / 2
  local w = self.width - self:hPadding() * 2
  local namePos = Vector(x, y, 0)
  local font = Fonts.gui_medium
  self.name = SimpleText(self.member.name, namePos, w, 'left', font)
  self.content:add(self.name)
  self.page = Pagination(self)
  self.content:add(self.page)
  self.page:set(1, #self.GUI.members)
end
-- Overrides EquipBonusWindow:createBonusText.
function ShopBonusWindow:createBonusText(att, x, y, w)
  EquipBonusWindow.createBonusText(self, att, x, y + 10, w)
end
-- Shows the bonus for the next member in the troop.
function ShopBonusWindow:nextMember()
  self:setMember(self.page.current + 1)
end
-- Shows the bonus for the previous member in the troop.
function ShopBonusWindow:prevMember()
  self:setMember(self.page.current - 1)
end
-- Shows the bonus for the given member.
-- @param(i : number) The position of the member in the troop.
function ShopBonusWindow:setMember(i)
  local page = math.mod1(i, #self.GUI.members)
  self.page:set(page, #self.GUI.members)
  self.name:setText(self.GUI.members[page].name)
  self.name:redraw()
end
-- Shows attribute bonus of the given item.
-- @param(item : table) The item data from database.
function ShopBonusWindow:setItem(item)
  if item.equip then
    self:showContent()
    --self:setEquip(item)
  else
    self:hideContent()
  end
end

return ShopBonusWindow