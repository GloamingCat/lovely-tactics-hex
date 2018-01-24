
--[[===============================================================================================

AttributeSet
---------------------------------------------------------------------------------------------------
Represents a set of battler attributes, stored by key.

=================================================================================================]]

-- Alias
local copyTable = util.table.shallowCopy

-- Constants
local attConfig = Config.attributes

local AttributeSet = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(battler : Battler) the battler with this attribute set
function AttributeSet:init(battler, save)
  self.battler = battler
  self.classBase = {}
  self.battlerBase = {}
  self.formula = {}
  local attBase = save and save.att or battler.data.attributes
  local build = battler.class.build
  for i = 1, #attConfig do
    local key = attConfig[i].key
    local script = attConfig[i].script
    -- Base values
    self.classBase[key] = build and build[key] and build[key](battler.class.level) or 0
    self.battlerBase[key] = attBase[key] or 0
    self.formula[key] = script ~= '' and loadformula(script, 'att')
    -- Total
    self[key] = function()
      local base = self:getBase(key)
      return self:getBonus(key, base, battler)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Attribute Values
---------------------------------------------------------------------------------------------------

-- @param(key : string) attribute's key
-- @ret(number) the basic attribute value, without volatile bonus
function AttributeSet:getBase(key)
  local base = self.classBase[key] + self.battlerBase[key]
  if self.formula[key] then
    return self.formula[key](self) + base
  else
    return base
  end
end
-- @param(key : string) attribute's key
-- @param(base : number) attribute's basic value
-- @param(battler : Battler) battler that contains the bonus information
-- @ret(number) the basic + the bonus value
function AttributeSet:getBonus(key, base, battler)
  local add1, mul1 = battler.statusList:attBonus(key)
  local add2, mul2 = battler.equipSet:attBonus(key)
  return add1 + add2 + base * (mul1 + mul2 + 1)
end

---------------------------------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------------------------------

-- @ret(table) persistent state of the battler's attributes
function AttributeSet:getState()
  return copyTable(self.battlerBase)
end

return AttributeSet