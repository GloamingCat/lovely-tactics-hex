
--[[===============================================================================================

BattlerBase
---------------------------------------------------------------------------------------------------
A class the holds character's information for battle formula.
Used only for access and display in GUI.

=================================================================================================]]

-- Imports
local Inventory = require('core/battle/Inventory')
local List = require('core/datastruct/List')
local SkillAction = require('core/battle/action/SkillAction')
local SkillList = require('core/battle/SkillList')
local StatusList = require('core/battle/StatusList')
local TagMap = require('core/datastruct/TagMap')

-- Alias
local copyArray = util.array.copy
local copyTable = util.table.shallowCopy
local deepCopyTable = util.table.deepCopy
local newArray = util.array.new
local readFile = love.filesystem.read
local sum = util.array.sum

-- Constants
local attConfig = Config.attributes
local equipTypes = Config.equipTypes
local elementCount = #Config.elements
local mhpName = Config.battle.attHP
local mspName = Config.battle.attSP
local jumpName = Config.battle.attJump
local stepName = Config.battle.attStep
local weightName = Config.battle.attWeight

local BattlerBase = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(member : table)
function BattlerBase:init(save)
  local id = save and save.battlerID or -1
  if id < 0 then
    local charID = save and save.charID
    local charData = Database.characters[charID]
    id = charData.battlerID
  end
  local data = Database.battlers[id]
  self.key = save.key
  self.charID = save.charID
  self.data = data
  self.name = data.name
  self.x = save.x
  self.y = save.y
  self.tags = TagMap(data.tags)
  self:initSkillList(save, data.skills or {}, data.attackID)
  self:initElements(save, data.elements or {})
  self:initInventory(save, data.items or {})
  self:initStatusList(save, data.status or {})
  self:initEquipment(save, data.equipment or {})
  self:createClassData(save, data.classID, data.level)
  self:createAttributes(save)
  self:createStateValues(save, data.attributes)
end
-- Creates and sets and array of element factors.
-- @param(elements : table) array of element factors 
--  (in percentage, 100 is neutral)
function BattlerBase:initElements(save, elements)
  self.elementFactors = save and save.elements and copyArray(save.elements)
  if not self.elementFactors then
    local e = newArray(elementCount, 0)
    for i = 1, #elements do
      e[elements[i].id] = (elements[i].value - 100) / 100
    end
    self.elementFactors = e
  end
end
-- Creates and sets the list of usable skills.
-- @param(skills : table) array of skill IDs
-- @param(attackID : number) ID of the battler's "Attack" skill
function BattlerBase:initSkillList(save, skills, attackID)
  -- Get from troop's persistent data
  if save then
    skills = save.skills or skills
    attackID = save.attackID or attackID
  end
  self.skillList = SkillList(skills)
  self.attackSkill = SkillAction:fromData(attackID)
end
-- Creates the initial status list.
function BattlerBase:initStatusList(save, initialStatus)
  initialStatus = save and save.status
  self.statusList = StatusList(self, initialStatus)
end
-- Initializes inventory from the given initial items slots.
function BattlerBase:initInventory(save, items)
  items = save and save.items or items
  self.inventory = Inventory(items)
end
-- Initialized equipment table.
function BattlerBase:initEquipment(save, equipment)
  if save and save.equipment then
    self.equipment = copyTable(save.equipment)
  else
    self.equipment = {}
  end
  for i = 1, #equipTypes do
    local slot = equipTypes[i]
    for k = 1, slot.count do
      local key = slot.key .. k
      local slotData = self.equipment[key] 
          or equipment[key] and deepCopyTable(equipment[key]) 
          or { id = -1, state = slot.state }
      self.equipment[key] = slotData
      if slotData.id >= 0 then
        local equip = Database.items[slotData.id]
        self.statusList:setEquip(key, equip)
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Attributes
---------------------------------------------------------------------------------------------------

function BattlerBase:createClassData(save, classID, level)
  if save then
    self.classID = save.classID or classID
    self.level = save.level or level
  else
    self.classID = classID
    self.level = level
  end
  local classData = Database.classes[self.classID]
  self.expCurve = loadformula(classData.expCurve, 'lvl')
  self.build = {}
  for i = 1, #attConfig do
    local key = attConfig[i].key
    if classData.build[key] then
      self.build[key] = loadformula(classData.build[key], 'lvl')
    end
  end
  self.classSkills = List(classData.skills)
  self.classSkills:sort(function(a, b) return a.level < b.level end)
end
-- Creates attribute functions from script data.
function BattlerBase:createAttributes()
  self.att = {}
  for i = 1, #attConfig do
    local key = attConfig[i].key
    local script = attConfig[i].script
    -- Base value
    local baseKey = key .. 'Base'
    if script == '' then
      local build = self.build[key] and self.build[key](self.level) or 0
      self.att[baseKey] = function()
        return self.attBase[key] + build
      end
    else
      local base = loadformula(script, 'att')
      self.att[baseKey] = function()
        return self.attBase[key] + base(self.att)
      end
    end
    -- Total
    self.att[key] = function()
      return self:attBonus(key, self.att[baseKey]())
    end
  end
  self.jumpPoints = self.att[jumpName]
  self.maxSteps = self.att[stepName]
  self.mhp = self.att[mhpName]
  self.msp = self.att[mspName]
end
-- Calculares the extra values for the given attribute.
-- @param(key : string) attribute's key
-- @param(base : number) the attribute's base value
-- @ret(number) the base added by the bonus
function BattlerBase:attBonus(key, base)
  local add, mul = self.statusList:attBonus(key)
  return add + base * mul
end
-- Initializes battler's state.
-- @param(save : table) persistent data
-- @param(attBase : table) array of the base values of each attribute
function BattlerBase:createStateValues(save, attBase)
  self.steps = 0
  if save then
    self.state = save.state and deepCopyTable(save.state)
    self.attBase = save.attBase and deepCopyTable(save.attBase)
    self.exp = save.exp
  end
  if not self.attBase then
    self.attBase = {}
    for i = 1, #attConfig do
      local key = attConfig[i].key
      self.attBase[key] = attBase[key] or 0
    end
  end
  if not self.state then
    self.state = {}
    self.state.hp = self.mhp()
    self.state.sp = self.msp()
  end
  self.exp = self.exp or self.expCurve(self.level)
end

---------------------------------------------------------------------------------------------------
-- Elements
---------------------------------------------------------------------------------------------------

-- Gets an element multiplying factor.
-- @param(id : number) the element's ID (position in the elements database)
function BattlerBase:element(id)
  return self.elementFactors[id] + self.statusList:elementBonus(id)
end

---------------------------------------------------------------------------------------------------
-- Equipment
---------------------------------------------------------------------------------------------------

function BattlerBase:setEquip(key, equip, battler)
  self.equipment[key].id = equip and equip.id or -1
  self.statusList:setEquip(key, equip, battler)
end

---------------------------------------------------------------------------------------------------
-- Level Up
---------------------------------------------------------------------------------------------------

function BattlerBase:addExperience(exp)
  self.exp = self.exp + exp
  while self.exp >= self.expCurve(self.level + 1) do
    self.level = self.level + 1
    for i = 1, #self.classSkills do
      local skill = self.classSkills[i]
      if self.level >= skill.level then
        self.skillList:learn(skill)
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Save
---------------------------------------------------------------------------------------------------

-- Creates a table that stores the battler's current state to be saved.
-- @ret(table)
function BattlerBase:createPersistentData()
  return {
    key = self.key,
    x = self.x,
    y = self.y,
    name = self.name,
    level = self.level,
    exp = self.exp,
    classID = self.classID,
    charID = self.charID,
    battlerID = self.data.id,
    state = self.state,
    attBase = self.attBase,
    elements = self.elementFactors,
    equipment = self.equipment,
    status = self.statusList:getState(),
    skills = self.skillList:getState() }
end

return BattlerBase
