
--[[===============================================================================================

CommandWindow
---------------------------------------------------------------------------------------------------


=================================================================================================]]

local GridWindow = require('core/gui/GridWindow')
local Button = require('core/gui/widget/Button')

--local ItemGUI = require('core/gui/item/ItemGUI')
local EquipGUI = require('core/gui/equip/EquipGUI')
--local SkillGUI = require('core/gui/skill/SkillGUI')
--local StatGUI = require('core/gui/stat/StatGUI')

local CommandWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------------------------------

function CommandWindow:createWidgets()
  Button:fromKey(self, 'items')
  Button:fromKey(self, 'equips')
  Button:fromKey(self, 'skills')
  Button:fromKey(self, 'stats')
end
-- Items button.
function CommandWindow:itemsConfirm()
  --self:showGUI(ItemGUI)
end
-- Equips button.
function CommandWindow:equipsConfirm()
  self:showGUI(EquipGUI)
end
-- Skills button.
function CommandWindow:skillsConfirm()
  --self:showGUI(SkillGUI)
end
-- Stats button.
function CommandWindow:statsConfirm()
  --self:showGUI(StatGUI)
end

---------------------------------------------------------------------------------------------------
-- Member GUI
---------------------------------------------------------------------------------------------------

-- Shows a sub GUI for the current member.
-- @param(GUI : class)
function CommandWindow:showGUI(GUI)
  local y = self.GUI.commandWindow.height + self.GUI:windowMargin() * 2
  local gui = GUI(self.GUI.member, y)
  self.GUI.subGUI = gui
  GUIManager:showGUIForResult(gui)
  self.GUI.subGUI = nil
end
-- Called when player presses "next" key.
function CommandWindow:onNext()
  self.GUI:nextMember()
end
-- Called when player presses "prev" key.
function CommandWindow:onPrev()
  self.GUI:prevMember()
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function CommandWindow:colCount()
  return 2
end
-- Overrides GridWindow:rowCount.
function CommandWindow:rowCount()
  return 2
end

return CommandWindow