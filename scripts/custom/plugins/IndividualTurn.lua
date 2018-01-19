
--[[===============================================================================================

IndividualTurn
---------------------------------------------------------------------------------------------------
System of turns per characters instead of per party.

=================================================================================================]]

-- Imports
local TurnManager = require('core/battle/TurnManager')
local Battler = require('core/battle/Battler')
local StatusList = require('core/battle/StatusList')
local BattleAction = require('core/battle/action/BattleAction')
local SkillAction = require('core/battle/action/SkillAction')
local WaitAction = require('core/battle/action/WaitAction')
local TargetWindow = require('core/gui/battle/window/TargetWindow')
local TurnWindow = require('core/gui/battle/window/TurnWindow')
local ActionGUI = require('core/gui/battle/ActionGUI')
local SimpleText = require('core/gui/widget/SimpleText')
local PriorityQueue = require('core/datastruct/PriorityQueue')
local Vector = require('core/math/Vector')

-- Alias
local max = math.max
local min = math.min
local ceil = math.ceil
local yield = coroutine.yield
local time = love.timer.getDelta

-- Parameters
local turnLimit = args.turnLimit
local attName = args.attName

---------------------------------------------------------------------------------------------------
-- Turn Manager
---------------------------------------------------------------------------------------------------

-- Override.
local TurnManager_init = TurnManager.init
function TurnManager:init()
  TurnManager_init(self)
  self.turnLimit = turnLimit
end
-- Override.
function TurnManager:nextParty()
  local char, iterations = self:getNextTurn()
  self.iterations = iterations
  self.turnCharacters = { char }
  self.characterIndex = 1
  self.party = char.battler.party
end
-- [COROUTINE] Searchs for the next character turn and starts.
-- @ret(Character) the next turn's character
-- @ret(number) the number of iterations it took from the previous turn
function TurnManager:getNextTurn()
  local turnQueue = self:getTurnQueue()
  local currentCharacter, iterations = turnQueue:front()
  self:incrementTurnCount(iterations)
  return currentCharacter, iterations
end
-- Sorts the characters according to which one's turn will star first.
-- @ret(PriorityQueue) the queue where which element is a character 
--  and each key is the remaining turn count until it's the character's turn
function TurnManager:getTurnQueue()
  local queue = PriorityQueue()
  for char in TroopManager.characterList:iterator() do
    if char.battler:isActive() then
      local time = char.battler:remainingTurnCount()
      queue:enqueue(char, time)
    end
  end
  return queue
end
-- Increments all character's turn count.
-- @param(time : number) the number of time iterations (1 by default)
-- @ret(Character) the character that reached turn limit (nil if none did)
function TurnManager:incrementTurnCount(time)
  time = time or 1
  for bc in TroopManager.characterList:iterator() do
    if bc.battler:isActive() then
      bc.battler:incrementTurnCount(time)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Battler
---------------------------------------------------------------------------------------------------

-- Override.
local Battler_init = Battler.init
function Battler:init(...)
  self.turnCount = 0
  Battler_init(self, ...)
end
-- Increments turn count by the turn attribute.
-- @param(time : number) a multiplier to the step (used for time bar animation)
function Battler:incrementTurnCount(time)
  self.turnCount = self.turnCount + self.att[attName]() * time
end
-- Decrements turn count by a value. It never reaches a negative value.
-- @param(value : number)
function Battler:decrementTurnCount(value)
  self.turnCount = max(self.turnCount - value, 0)
end
-- Returns the number of steps needed to reach turn limit.
-- @ret(number) the number of steps (float)
function Battler:remainingTurnCount()
  return (turnLimit - self.turnCount) / self.att[attName]()
end
-- Override. Decrements turn count.
local Battler_turnEnd = Battler.onSelfTurnEnd
function Battler:onSelfTurnEnd(result)
  local maxSteps = self.maxSteps()
  local stepCost = (maxSteps - self.steps) / maxSteps
  local cost = result.timeCost or 0
  local totalCost = ceil((stepCost + cost) / 2 * turnLimit)
  self:decrementTurnCount(totalCost)
  Battler_turnEnd(self, result)
end

---------------------------------------------------------------------------------------------------
-- StatusList
---------------------------------------------------------------------------------------------------

-- Override.
function StatusList:onTurnStart(...)
  local i = 1
  while i <= self.size do
    local status = self[i]
    status.state.lifeTime = status.state.lifeTime + _G.TurnManager.iterations
    status:onTurnStart(...)
    if status.state.lifeTime > status.duration * turnLimit then
      self:removeStatus(status)
    else
      i = i + 1
    end
  end
end

---------------------------------------------------------------------------------------------------
-- BattleAction
---------------------------------------------------------------------------------------------------

-- Override.
local BattleAction_execute = BattleAction.execute
function BattleAction:execute(input)
  local result = BattleAction_execute(self, input)
  if self.timeCost then
    result.timeCost = self.timeCost(self, input.user.battler.att)
  else
    result.timeCost = 100
  end
  return result
end

---------------------------------------------------------------------------------------------------
-- SkillAction
---------------------------------------------------------------------------------------------------

-- Override.
local SkillAction_init = SkillAction.init
function SkillAction:init(...)
  SkillAction_init(self, ...)
  if self.tags.timeCost then
    self.timeCost = loadformula(self.tags.timeCost, 'action, att')
  end
end

---------------------------------------------------------------------------------------------------
-- WaitAction
---------------------------------------------------------------------------------------------------

-- Override.
local WaitAction_confirm = WaitAction.onConfirm
function WaitAction:onConfirm(...)
  local result = WaitAction_confirm(self, ...)
  result.timeCost = 50
  return result
end

---------------------------------------------------------------------------------------------------
-- TargetWindow
---------------------------------------------------------------------------------------------------

-- Override.
local TargetWindow_init = TargetWindow.init
function TargetWindow:init(GUI, showTC)
  self.showTC = showTC
  TargetWindow_init(self, GUI)
end
-- Override.
local TargetWindow_height = TargetWindow.calculateHeight
function TargetWindow:calculateHeight()
  if self.showTC then
    return TargetWindow_height(self) + 10
  else
    return TargetWindow_height(self)
  end
end
-- Override.
local TargetWindow_content = TargetWindow.createContent
function TargetWindow:createContent(width, height)
  TargetWindow_content(self, width, height)
  -- Turn count text
  if self.showTC then
    local x = -self.width / 2 + self:hPadding()
    local y = -self.height / 2 + self:vPadding()
    local w = self.width - self:hPadding() * 2
    local pos = Vector(x, y + 35)
    self.textTC = self:addStateVariable(Vocab.turnCount, pos, w)
  end
end
-- Override.
local TargetWindow_setBattler = TargetWindow.setBattler
function TargetWindow:setBattler(battler)
  TargetWindow_setBattler(self, battler)
  -- Turn count value
  if self.showTC then
    if battler then
      local tc = (battler.turnCount / _G.TurnManager.turnLimit * 100)
      self.textTC:show()
      self.textTC:setText(string.format( '%3.0f', tc ) .. '%')
      self.textTC:redraw()
    else
      self.textTC:hide()
    end
  end
end

---------------------------------------------------------------------------------------------------
-- ActionGUI
---------------------------------------------------------------------------------------------------

-- Override.
function ActionGUI:createTargetWindow()
  if not self.targetWindow then
    local window = TargetWindow(self, true)
    self.targetWindow = window
    window:setVisible(false)
  end
  return self.targetWindow
end
