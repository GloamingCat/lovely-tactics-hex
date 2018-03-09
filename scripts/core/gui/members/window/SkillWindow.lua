
--[[===============================================================================================

SkillWindow
---------------------------------------------------------------------------------------------------
The window that shows the list of skills to be used.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')
local Button = require('core/gui/widget/Button')
local ListButtonWindow = require('core/gui/ListButtonWindow')
local MenuTargetGUI = require('core/gui/general/MenuTargetGUI')
local Vector = require('core/math/Vector')

-- Constants
local spName = Config.battle.attSP

local SkillWindow = class(ListButtonWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(GUI : GUI)
function SkillWindow:init(GUI, ...)
  self.member = GUI.memberGUI:currentMember()
  ListButtonWindow.init(self, self.member.skillList, GUI, ...)
end
-- @param(member : Battler)
function SkillWindow:setMember(member)
  self.member = member
  self:refreshButtons()
end
-- Creates a button from an item ID.
-- @param(id : number) the item ID
function SkillWindow:createListButton(skill)
  -- Icon
  local icon = skill.data.icon.id >= 0 and 
    ResourceManager:loadIconAnimation(skill.data.icon, GUIManager.renderer)
  -- Button
  local button = Button(self)
  button:createIcon(icon)
  button:createText(skill.data.name, 'gui_medium')
  button.skill = skill
  button.description = skill.data.description
  -- Get SP cost
  local cost = 0
  for i = 1, #skill.costs do
    if skill.costs[i].key == spName then
      cost = cost + skill.costs[i].cost(skill, self.member.att)
    end
  end
  button:createInfoText(cost .. Vocab.sp, 'gui_medium')
  return button
end

---------------------------------------------------------------------------------------------------
-- Input handlers
---------------------------------------------------------------------------------------------------

-- Called when player chooses an item.
-- @param(button : Button) the button selected
function SkillWindow:onButtonConfirm(button)
  local input = ActionInput(button.skill, self.member)
  if button.skill:isArea() then
    -- Use in all members
    input.targets = self.member.troop.current
    input.action:menuUse(input)
    self.GUI.memberGUI:refreshMember()
  else
    -- Choose a target
    local memberGUI = self.GUI.memberGUI
    GUIManager.fiberList:fork(memberGUI.hide, memberGUI)
    self.GUI:hide()
    local gui = MenuTargetGUI(self.member.troop)
    gui.input = input
    GUIManager:showGUIForResult(gui)
    GUIManager.fiberList:fork(memberGUI.show, memberGUI)
    _G.Fiber:wait()
    self.GUI:show()
  end
  for i = 1, #self.matrix do
    self.matrix[i]:updateEnabled()
    self.matrix[i]:refreshState()
  end
end
-- Updates description when button is selected.
-- @param(button : Button)
function SkillWindow:onButtonSelect(button)
  self.GUI.descriptionWindow:setText(button.description)
end
-- Called when player presses "next" key.
function SkillWindow:onNext()
  self.GUI.memberGUI:nextMember()
end
-- Called when player presses "prev" key.
function SkillWindow:onPrev()
  self.GUI.memberGUI:prevMember()
end
-- Tells if an item can be used.
-- @param(button : Button) the button to check
-- @ret(boolean)
function SkillWindow:buttonEnabled(button)
  return self.member:isActive() and button.skill and button.skill:canMenuUse(self.member)
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function SkillWindow:colCount()
  return 2
end
-- Overrides GridWindow:rowCount.
function SkillWindow:rowCount()
  return 6
end
-- @ret(string) String representation (for debugging).
function SkillWindow:__tostring()
  return 'SkillWindow'
end

return SkillWindow