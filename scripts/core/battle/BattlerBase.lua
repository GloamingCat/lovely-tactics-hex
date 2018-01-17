
--[[===============================================================================================

BattlerBase
---------------------------------------------------------------------------------------------------
A class the holds character's information for battle formula.
Used only for access and display in GUI.

=================================================================================================]]

-- Imports
local List = require('core/datastruct/List')
local SkillList = require('core/battle/SkillList')
local SkillAction = require('core/battle/action/SkillAction')
local Inventory = require('core/battle/Inventory')
local StatusList = require('core/battle/StatusList')
local TagMap = require('core/datastruct/TagMap')

-- Alias
local readFile = love.filesystem.read
local newArray = util.array.new
local copyArray = util.array.copy
local copyTable = util.table.shallowCopy
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
-- @param(data : table) battler's data from database
-- @param(save : table) data from save, if any (optional)
function BattlerBase:init(key, data, save)
  self.key = key
  self.data = data
  self.save = save
  self.name = data.name
  self.tags = TagMap(data.tags)
  self:initSkillList(data.skills or {}, data.attackID)
  self:initElements(data.elements or {})
  self:initInventory(data.items or {})
  self:initStatusList(data.status or {})
  self:initEquipment(data.equipment or {})
  self:createClassData(data.classID, data.level)
  self:createAttributes()
  self:createStateValues(data.attributes)
end
function BattlerBase:fromMember(member, save)
  local id = save and save.battlerID or member.battlerID
  if id < 0 then
    local charID = save and save.charID or member.charID
    local charData = Database.characters[charID]
    id = charData.battlerID
  end
  local data = Database.battlers[id]
  return self(member.kay, data, save)
end
-- Creates and sets and array of element factors.
-- @param(elements : table) array of element factors 
--  (in percentage, 100 is neutral)
function BattlerBase:initElements(elements)
  self.elementFactors = self.save and copyArray(self.save.elements)
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
function BattlerBase:initSkillList(skills, attackID)
  -- Get from troop's persistent data
  if self.save then
    skills = self.save.skills or skills
    attackID = self.save.attackID or attackID
  end
  self.skillList = SkillList(skills)
  self.attackSkill = SkillAction:fromData(attackID)
end
-- Creates the initial status list.
function BattlerBase:initStatusList(initialStatus)
  initialStatus = self.save and self.save.status
  self.statusList = StatusList(self, initialStatus)
end
-- Initializes inventory from the given initial items slots.
function BattlerBase:initInventory(items)
  items = self.save and self.save.items or items
  self.inventory = Inventory(items)
end
-- Initialized equipment table.
function BattlerBase:initEquipment(equip)
  self.equipment = {}
  for i = 1, #equipTypes do
    local slot = equipTypes[i]
    for k = 1, slot.count do
      local key = slot.key .. k
      self.equipment[key] = equip[key] and copyTable(equip[key]) or {
        id = -1,
        freedom = slot.freedom }
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Attributes
---------------------------------------------------------------------------------------------------

function BattlerBase:createClassData(classID, level)
  if self.save then
    self.classID = self.save.classID
    self.level = self.save.level
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
    local build = self.build[key] and self.build[key](self.level) or 0
    if script == '' then
      self.att[key] = function()
        local add, mul = self.statusList:attBonus(key)
        return add + mul * (self.attBase[key] + build)
      end
    else
      local base = loadformula(script, 'att')
      self.att[key] = function()
        local add, mul = self.statusList:attBonus(key)
        return add + mul * (base(self.att) + self.attBase[key] + build)
      end
    end
  end
  self.jumpPoints = self.att[jumpName]
  self.maxSteps = self.att[stepName]
  self.mhp = self.att[mhpName]
  self.msp = self.att[mspName]
end
-- Initializes battler's state.
-- @param(data : table) persistent data
-- @param(attBase : table) array of the base values of each attribute
-- @param(build : table) the build with the base functions for each attribute
-- @param(level : number) battler's level
function BattlerBase:createStateValues(attBase)
  self.steps = 0
  if self.save then
    self.state = copyTable(self.save.state)
    self.attBase = copyTable(self.save.attBase)
    self.elementFactors = self.save.elements
    self.exp = self.save.exp
  else
    self.state = {}
    self.attBase = {}
    for i = 1, #attConfig do
      local key = attConfig[i].key
      self.attBase[key] = attBase[key] or 0
    end
    self.exp = self.expCurve(self.level)
    self.state.hp = self.mhp()
    self.state.sp = self.msp()
  end
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
    name = self.name,
    level = self.level,
    exp = self.exp,
    classID = self.classID,
    state = self.state,
    attBase = self.attBase,
    elements = self.elementFactors,
    equipment = self.equipment,
    status = self.statusList:getState(),
    skills = self.skillList:getState() }
end

return BattlerBase
