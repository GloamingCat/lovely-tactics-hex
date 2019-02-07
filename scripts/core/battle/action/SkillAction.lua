
--[[===============================================================================================

SkillAction
---------------------------------------------------------------------------------------------------
The BattleAction that is executed when players chooses a skill to use.

=================================================================================================]]

-- Imports
local ActionInput = require('core/battle/action/ActionInput')
local BattleAction = require('core/battle/action/BattleAction')
local List = require('core/base/datastruct/List')
local BattleMoveAction = require('core/battle/action/BattleMoveAction')
local PathFinder = require('core/battle/ai/PathFinder')
local PopupText = require('core/battle/PopupText')
local TagMap = require('core/base/datastruct/TagMap')

-- Alias
local max = math.max
local isnan = math.isnan
local mathf = math.field
local time = love.timer.getDelta
local now = love.timer.getTime
local random = math.random
local round = math.round

-- Constants
local elementCount = #Config.elements

local SkillAction = class(BattleAction)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor. Creates the action from a skill ID.
-- @param(skillID : number) the skill's ID from database
function SkillAction:init(skillID)
  local data = Database.skills[skillID]
  self.data = data
  BattleAction.init(self, nil, data.castRange, data.effectRange)
  self:setType(data.type)
  self:setTargetType(data.targetType)
  -- Time before initial animation starts.
  self.introTime = tonumber(data.introTime) or 20
  -- Time after cast animation starts and before user steps back to tile.
  self.castTime = tonumber(data.castTime) or 10
  -- Time after cast animation starts and before starting individual target animations.
  self.centerTime = tonumber(data.centerTime) or 10
  -- Time between start of each individual target animation.
  self.targetTime = tonumber(data.targetTime) or 0
  -- Time after all animations finished.
  self.finishTime = tonumber(data.finishTime) or 0
  -- Cost formulas
  self.costs = {}
  for i = 1, #data.costs do
    self.costs[i] = {
      cost = loadformula(data.costs[i].value, 'action, att'),
      key = data.costs[i].key }
  end
  -- Effect formulas
  self.effects = {}
  for i = 1, #data.effects do
    self:addEffect(data.effects[i])
  end
  -- Status to add
  self.status = {}
  self:addStatus(data.statusAdd, true)
  self:addStatus(data.statusRemove, false)
  -- Store elements
  local e = {}
  for i = 1, #data.elements do
    e[data.elements[i].id + 1] = data.elements[i].value
  end
  for i = 1, elementCount do
    if not e[i] then
      e[i] = 0
    end
  end
  self.elements = e
  -- Tags
  self.tags = TagMap(data.tags)
end
-- Creates an SkillAction given the skill's ID in the database, depending on the skill's script.
-- @param(skillID : number) the skill's ID in database
function SkillAction:fromData(skillID, ...)
  local data = Database.skills[skillID]
  if data.script ~= '' then
    local class = require('custom/' .. data.script)
    return class(skillID, ...)
  else
    return self(skillID, ...)
  end
end
-- @ret(string) A string with skill's ID and name.
function SkillAction:__tostring()
  return 'SkillAction (' .. self.data.id .. ': ' .. self.data.name .. ')'
end

---------------------------------------------------------------------------------------------------
-- Damage / Status
---------------------------------------------------------------------------------------------------

-- Inserts a new effect in this skill.
-- @param(key : string) The name of the effect's destination (hp or sp).
-- @param(effect : table) Effect's properties (basicResult, successRate, heal and absorb).
function SkillAction:addEffect(effect)
  self.effects[#self.effects + 1] = { key = effect.key,
    basicResult = loadformula(effect.basicResult, 'action, a, b, rand'),
    successRate = loadformula(effect.successRate, 'action, a, b, rand'),
    heal = effect.heal,
    absorb = effect.absorb }
end
-- Inserts a new status in this skill.
-- @param(status : table) Array with each status (id, rate, add).
function SkillAction:addStatus(status, add)
  local last = #self.status
  for i = 1, #status do
    self.status[last + i] = { id = status[i].id, add = add,
      rate = loadformula(status[i].rate, 'action, a, b, rand') }
  end
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:canExecute.
-- @param(input : ActionInput)
-- @ret(boolean)
function SkillAction:canExecute(input)
  return self:canBattleUse(input.user)
end
-- Overrides BattleAction:onConfirm.
-- Executes the movement action and the skill's effect.
function SkillAction:execute(input)
  local moveAction = BattleMoveAction(self.range)
  local moveInput = ActionInput(moveAction, input.user, input.target)
  moveInput.skipAnimations = input.skipAnimations
  local result = moveInput:execute(moveInput)
  if result.executed then    
    -- Skill use
    self:battleUse(input)
    return BattleAction.execute(self, input)
  else
    return { executed = false, endCharacterTurn = true }
  end
end
-- @param(user : Battler)
function SkillAction:canUse(user)
  local att = user.att
  local state = user.state
  for i = 1, #self.costs do
    local cost = self.costs[i].cost(self, att)
    local key = self.costs[i].key
    if cost > state[key] then
      return false
    end
  end
  return true
end

---------------------------------------------------------------------------------------------------
-- Battle Use
---------------------------------------------------------------------------------------------------

-- Checks if the skill can be used in the battle field.
-- @param(user : Character)
-- @ret(boolean)
function SkillAction:canBattleUse(user)
  return self:canUse(user.battler)
end
-- The effect applied when the user is prepared to use the skill.
-- It executes animations and applies damage/heal to the targets.
function SkillAction:battleUse(input)
  -- Apply costs
  input.user.battler:damageCosts(self.costs)
  -- Intro time.
  _G.Fiber:wait(self.introTime)
  -- User's initial animation.
  local originTile = input.user:getTile()
  local dir = input.user:turnToTile(input.target.x, input.target.y)
  dir = math.angle2Row(dir) * 45
  _G.Fiber:wait(input.user:loadSkill(self.data, dir))
  -- Cast animation.
  FieldManager.renderer:moveToTile(input.target)
  local minTime = input.user:castSkill(self.data, dir, input.target) + GameManager.frame
  input.user.battler:onSkillUse(input, input.user)
  -- Return user to original position and animation.
  _G.Fiber:fork(function()
    _G.Fiber:wait(self.castTime)
    if not input.user:moving() then
      input.user:finishSkill(originTile, self.data)
    end
  end)
  -- Target animations
  _G.Fiber:wait(self.centerTime)
  self:allTargetsEffect(input, originTile)
  -- Wait until everything finishes.
  _G.Fiber:wait(max(minTime - GameManager.frame, 0) + self.finishTime)
end

---------------------------------------------------------------------------------------------------
-- Menu Use
---------------------------------------------------------------------------------------------------

-- Checks if the given character can use the skill, considering skill's costs.
-- @param(user : Battler)
-- @ret(boolean)
function SkillAction:canMenuUse(user)
  return self:canUse(user) and self.support
end
-- Executes the skill in the menu, out of the battle field.
-- @param(user : Battler)
-- @param(target : Battler)
function SkillAction:menuUse(input)
  if input.target then
    local results = self:calculateEffectResults(input.user, input.target)
    local char = TroopManager:getBattlerCharacter(input.target)
    input.target:applyResults(results, char)
    input.target:onSkillEffect(input, results, char)
  elseif input.targets then
    for i = 1, #input.targets do
      local results = self:calculateEffectResults(input.user, input.targets[i])
      local char = TroopManager:getBattlerCharacter(input.targets[i])
      input.targets[i]:applyResults(results, char)
      input.targets[i]:onSkillEffect(input, results, char)
    end
  else
    return { executed = false }
  end
  input.user:damageCosts(self.costs)
  if self.data.castAnimID >= 0 then
    BattleManager:playMenuAnimation(self.data.castAnimID, false)
  end
  input.user:onSkillUse(input, TroopManager:getBattlerCharacter(input.user))
  return BattleAction.execute(self, input)
end

---------------------------------------------------------------------------------------------------
-- Effect result
---------------------------------------------------------------------------------------------------

-- Tells if a character may receive the skill's effects.
-- @param(char : Character)
function SkillAction:receivesEffect(char)
  return char.battler and char.battler:isAlive()
end
-- Calculates the final damage / heal for the target.
-- It considers all element bonuses provided by the skill data.
-- @param(user : Battler)
-- @param(target : Battler)
function SkillAction:calculateEffectResults(user, target)
  local points = {}
  local dmg = false
  for i = 1, #self.effects do
    local r = self:calculateEffectResult(self.effects[i], user, target)
    if r then
      points[#points + 1] = { value = r,
        key = self.effects[i].key,
        heal = self.effects[i].heal,
        absorb = self.effects[i].absorb }
      dmg = dmg or not self.effects[i].heal
    end
  end
  local status, sdmg = self:calculateStatusResult(user, target)
  local results = { damage = dmg or sdmg,
    points = points,
    status = status }
  return results
end
-- Calculates the final damage / heal for the target from an specific effect.
-- It considers all element bonuses provided by the skill data.
function SkillAction:calculateEffectResult(effect, user, target)
  local rand = self.rand or random
  local rate = effect.successRate(self, user.att, target.att, rand)
  if rand() * 100 > rate then
    return nil
  end
  local result = max(effect.basicResult(self, user.att, target.att, rand), 0)
  local bonus = 0
  for i = 1, elementCount do
    local el = self.elements[i] + (self.data.userElement and user:elementAtk(i) or 0)
    bonus = bonus + el * target:elementDef(i)
  end
  bonus = result * bonus
  return round(bonus + result)
end
-- @param(status : table) array with skill's status info
-- @param(user : Character)
-- @param(target : Character)
-- @param(rand : function)
-- @ret(table) array with status results
function SkillAction:calculateStatusResult(user, target)
  local rand = self.rand or random
  local result = {}
  local dmg = false
  for i = 1, #self.status do
    local s = self.status[i]
    local r = s.rate(self, user.att, target.att, rand)
    if rand() * 100 <= r then
      result[#result + 1] = {
        id = s.id,
        add = s.add }
      dmg = dmg or s.add
    end
  end
  return result, dmg
end

---------------------------------------------------------------------------------------------------
-- Target Animations
---------------------------------------------------------------------------------------------------

-- Executes individual animation for all the affected tiles.
-- @param(originTile : ObjectTile) the user's original tile
function SkillAction:allTargetsEffect(input, originTile)
  local allTargets = self:getAllAffectedTiles(input)
  for i = #allTargets, 1, -1 do
    for targetChar in allTargets[i].characterList:iterator() do
      if self:receivesEffect(targetChar) then
        local results = self:calculateEffectResults(input.user.battler, targetChar.battler)
        self:singleTargetEffect(results, input, targetChar, originTile)
      end
    end
  end
  return allTargets
end
-- Executes individual animation for a single tile.
-- @param(targetChar : Character) the character that will be affected
-- @param(originTile : ObjectTile) the user's original tile
function SkillAction:singleTargetEffect(results, input, targetChar, originTile)
  if #results.points == 0 and #results.status == 0 then
    -- Miss
    local pos = targetChar.position
    local popupText = PopupText(pos.x, pos.y - 10, pos.z - 60)
    popupText:addLine(Vocab.miss, 'popup_miss', 'popup_miss')
    popupText:popup()
  else
    local wasAlive = targetChar.battler.state.hp > 0
    targetChar.battler:popupResults(targetChar.position, results, targetChar)
    if self.data.individualAnimID >= 0 then
      local dir = targetChar:tileToAngle(originTile.x, originTile.y)
      local mirror = dir > 90 and dir <= 270
      local pos = targetChar.position
      BattleManager:playBattleAnimation(self.data.individualAnimID,
        pos.x, pos.y, pos.z - 10, mirror)
    end
    if results.damage and self.data.damageAnim and wasAlive then
      if self:isArea() then
        originTile = input.target
      end
      _G.Fiber:fork(function()
        targetChar:damage(self.data, originTile, results)
      end)
    end
    if targetChar.battler.state.hp > 0 then
      targetChar:playAnimation(targetChar.idleAnim)
    end
  end
  targetChar.battler:onSkillEffect(input, results, targetChar)
  _G.Fiber:wait(self.targetTime)
  return results
end

return SkillAction