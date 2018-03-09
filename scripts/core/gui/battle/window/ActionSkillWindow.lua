
--[[===============================================================================================

ActionSkillWindow
---------------------------------------------------------------------------------------------------
The window that is open to choose a skill from character's skill list.

=================================================================================================]]

-- Imports
local ActionWindow = require('core/gui/battle/window/ActionWindow')
local Button = require('core/gui/widget/Button')
local ListButtonWindow = require('core/gui/ListButtonWindow')
local Vector = require('core/math/Vector')

-- Constants
local spName = Config.battle.attSP

local ActionSkillWindow = class(ActionWindow, ListButtonWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(GUI : GUI)
-- @param(skillList : SkillList)
function ActionSkillWindow:init(GUI, skillList)
  local m = GUI:windowMargin()
  local w = ScreenManager.width - GUI:windowMargin() * 2
  local h = ScreenManager.height * 4 / 5 - self:vPadding() * 2 - m * 3
  self.visibleRowCount = math.floor(h / self:cellHeight())
  local fith = self.visibleRowCount * self:cellHeight() + self:vPadding() * 2
  local pos = Vector(0, fith / 2 - ScreenManager.height / 2 + m / 2, 0)
  ListButtonWindow.init(self, skillList, GUI, w, h, pos)
end
-- Creates a button from a skill ID.
-- @param(skill : SkillAction) the SkillAction from battler's skill list
function ActionSkillWindow:createListButton(skill)
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
  local char = TurnManager:currentCharacter()
  local cost = 0
  for i = 1, #skill.costs do
    if skill.costs[i].key == spName then
      cost = cost + skill.costs[i].cost(skill, char.battler.att)
    end
  end
  button:createInfoText(cost .. Vocab.sp, 'gui_medium')
  return button
end

---------------------------------------------------------------------------------------------------
-- Input handlers
---------------------------------------------------------------------------------------------------

-- Updates description when button is selected.
function ActionSkillWindow:onButtonSelect(button)
  self.GUI.descriptionWindow:setText(button.description)
end
-- Called when player chooses a skill.
-- @param(button : Button) the button selected
function ActionSkillWindow:onButtonConfirm(button)
  self:selectAction(button.skill)
end
-- Tells if a skill can be used.
-- @param(button : Button) the button to check
-- @ret(boolean)
function ActionSkillWindow:buttonEnabled(button)
  local user = TurnManager:currentCharacter()
  return button.skill:canBattleUse(user) and self:skillActionEnabled(button.skill)
end
-- Called when player cancels.
function ActionSkillWindow:onCancel()
  self.GUI:hideDescriptionWindow()
  self:changeWindow(self.GUI.turnWindow)
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- New col count.
function ActionSkillWindow:colCount()
  return 2
end
-- New row count.
function ActionSkillWindow:rowCount()
  return self.visibleRowCount
end
-- String identifier.
function ActionSkillWindow:__tostring()
  return 'Skill Window'
end

return ActionSkillWindow
