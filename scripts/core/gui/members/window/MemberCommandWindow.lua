
--[[===============================================================================================

MemberCommandWindow
---------------------------------------------------------------------------------------------------


=================================================================================================]]

local GridWindow = require('core/gui/GridWindow')
local Button = require('core/gui/widget/Button')

--local ItemGUI = require('core/gui/item/ItemGUI')
local EquipGUI = require('core/gui/equip/EquipGUI')
--local SkillGUI = require('core/gui/skill/SkillGUI')
--local StatGUI = require('core/gui/stat/StatGUI')

local MemberCommandWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------------------------------

function MemberCommandWindow:createWidgets()
  Button:fromKey(self, 'items')
  Button:fromKey(self, 'equips')
  Button:fromKey(self, 'skills')
  Button:fromKey(self, 'stats')
end
-- Items button.
function MemberCommandWindow:itemsConfirm()
  --self:showGUI(ItemGUI)
end
-- Equips button.
function MemberCommandWindow:equipsConfirm()
  self:showGUI(EquipGUI)
end
-- Skills button.
function MemberCommandWindow:skillsConfirm()
  --self:showGUI(SkillGUI)
end
-- Stats button.
function MemberCommandWindow:statsConfirm()
  --self:showGUI(StatGUI)
end

---------------------------------------------------------------------------------------------------
-- Member GUI
---------------------------------------------------------------------------------------------------

-- Shows a sub GUI for the current member.
-- @param(GUI : class)
function MemberCommandWindow:showGUI(GUI)
  self.cursor:hide()
  self.GUI:showSubGUI(GUI)
  self.cursor:show()
end
-- Called when player presses "next" key.
function MemberCommandWindow:onNext()
  self.GUI:nextMember()
end
-- Called when player presses "prev" key.
function MemberCommandWindow:onPrev()
  self.GUI:prevMember()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function MemberCommandWindow:colCount()
  return 2
end
-- Overrides GridWindow:rowCount.
function MemberCommandWindow:rowCount()
  return 2
end

return MemberCommandWindow