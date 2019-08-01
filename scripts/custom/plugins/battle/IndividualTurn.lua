
--[[===============================================================================================

IndividualTurn
---------------------------------------------------------------------------------------------------
System of turns per characters instead of per party.
A turn count is associated to each character. At the start of each turn, this count is incremented
by the character's speed. This is done in a loop until some character reaches the turn count limit.

-- Plugin parameters:
The speed is calculated by a battler attribute, given by its name <attName>.
The turn limit is defined by <turnLimit>.

-- Skill parameters:
The default turn cost of a skill is 100% of the character's turn count by default, but this number
may be customized by the <timeCost> tag.

-- Status parameters:
The drain occurs each <drainTurns> turn iterations. It is set to 1 (every turn) by default.

=================================================================================================]]

-- Imports
local ActionGUI = require('core/gui/battle/ActionGUI')
local BattleAction = require('core/battle/action/BattleAction')
local Battler = require('core/battle/battler/Battler')
local Character = require('core/objects/Character')
local PriorityQueue = require('core/datastruct/PriorityQueue')
local SimpleText = require('core/gui/widget/SimpleText')
local SkillAction = require('core/battle/action/SkillAction')
local Status = require('core/battle/battler/Status')
local StatusList = require('core/battle/battler/StatusList')
local TargetWindow = require('core/gui/battle/window/TargetWindow')
local TurnManager = require('core/battle/TurnManager')
local TurnWindow = require('core/gui/battle/window/TurnWindow')
local Vector = require('core/math/Vector')
local WaitAction = require('core/battle/action/WaitAction')

-- Alias
local max = math.max
local min = math.min
local ceil = math.ceil
local yield = coroutine.yield
local time = love.timer.getDelta

-- Parameters
local turnLimit = tonumber(args.turnLimit)
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
  self.party = char.party
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
  for char in TroopManager.characterList:iterator() do
    if char.battler:isActive() then
      char.battler:incrementTurnCount(time)
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

---------------------------------------------------------------------------------------------------
-- Character
---------------------------------------------------------------------------------------------------

-- Override. Decrements turn count.
local Character_onSelfTurnEnd = Character.onSelfTurnEnd
function Character:onSelfTurnEnd(result)
  local maxSteps = self.battler.maxSteps()
  local stepCost = (maxSteps - self.steps) / maxSteps
  local cost = result.timeCost or 0
  local totalCost = ceil((stepCost + cost) / 2 * turnLimit)
  self.battler:decrementTurnCount(totalCost)
  Character_onSelfTurnEnd(self, result)
end

---------------------------------------------------------------------------------------------------
-- StatusList
---------------------------------------------------------------------------------------------------

-- Override. Adds iterations to lifeTime instead of just incrementing it by 1.
function StatusList:onTurnStart(char, ...)
  local i = 1
  while i <= self.size do
    local status = self[i]
    status.lifeTime = status.lifeTime + _G.TurnManager.iterations
    status:onTurnStart(char, ...)
    if status.lifeTime > status.duration * turnLimit / 10 then
      self:removeStatus(status, char)
    else
      i = i + 1
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Status
---------------------------------------------------------------------------------------------------

-- Override. Initializes drain count.
local Status_init = Status.init
function Status:init(...)
  Status_init(self, ...)
  if self.data.drainAtt ~= '' then
    self.drainCount = 0
    self.frequency = tonumber(self.tags.drainTurns) or 1
  end
end
-- Override. Checks if drain count reached frequency.
local Status_drain = Status.drain
function Status:drain(character)
  self.drainCount = self.drainCount + _G.TurnManager.iterations
  if self.drainCount > self.frequency then
    self.drainCount = self.drainCount - self.frequency
    Status_drain(self, character)
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
function TargetWindow:calculateHeight(showStatus)
  if self.showTC then
    return TargetWindow_height(self, showStatus) + 10
  else
    return TargetWindow_height(self, showStatus)
  end
end
-- Override.
local TargetWindow_content = TargetWindow.createContent
function TargetWindow:createContent(width, height)
  TargetWindow_content(self, width, height)
  -- Turn count text
  if self.showTC then
    local w = self.width - self:paddingX() * 2
    local pos = self.gaugeSP.topLeft:clone()
    pos.x = pos.x - 30
    pos.y = pos.y + 10
    self.gaugeTC = self:addStateVariable(Vocab.turnCount, pos, w, Color.barTC)
    self.gaugeTC.percentage = true
    self.iconList.topLeft.y = self.iconList.topLeft.y + 10
  end
end
-- Override.
local TargetWindow_setBattler = TargetWindow.setBattler
function TargetWindow:setBattler(battler)
  -- Turn count value
  if self.showTC then
    self.gaugeTC:setValues(battler.turnCount, _G.TurnManager.turnLimit)
  end
  TargetWindow_setBattler(self, battler)
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
