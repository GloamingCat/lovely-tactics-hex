
--[[===============================================================================================

EquipSet
---------------------------------------------------------------------------------------------------
Represents the equipment set of a battler.

=================================================================================================]]

-- Alias
local deepCopyTable = util.table.deepCopy

-- Constants
local attConfig = Config.attributes
local equipTypes = Config.equipTypes

local EquipSet = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(battler : Battler) this set's battler
-- @param(save : table) battler's save data (optional)
function EquipSet:init(battler, save)
  self.battler = battler
  self.slots = {}
  self.types = {}
  self.bonus = {}
  local equips = save and save.equips
  if equips then
    self.slots = deepCopyTable(equips.slots)
    self.types = deepCopyTable(equips.types)
  else
    local equips = battler.data.equipment
    for i = 1, #equipTypes do
      local slot = equipTypes[i]
      for k = 1, slot.count do
        local key = slot.key .. k
        local slotData = equips and equips[key] and deepCopyTable(equips[key]) or { id = -1 }
        self.slots[key] = slotData
        if slotData.id >= 0 then
          local data = Database.items[slotData.id]
          self:addStatus(data.equip)
        end
      end
      self.types[slot.key] = { state = slot.state, count = slot.count }
    end
  end
  for k in pairs(self.slots) do
    self:updateSlotBonus(k)
  end
end

---------------------------------------------------------------------------------------------------
-- Equip / Unequip
---------------------------------------------------------------------------------------------------

-- Gets the ID of the current equip in the given slot.
-- @param(key : string) slot's key
-- @ret(number) the ID of the equip item (-1 if none)
function EquipSet:getEquip(key)
  assert(self.slots[key], 'Slot ' .. key .. ' does not exist.')
  return Database.items[self.slots[key].id]
end
-- Sets the equip item in the given slot.
-- @param(key : string) slot's key
-- @param(item : table) item's data from database
-- @param(inventory : Inventory) troop's inventory
-- @param(character : Character) battler's character, in case it's during battle (optional)
function EquipSet:setEquip(key, item, inventory, character)
  if item then
    assert(item.equip, 'Item is not an equipment: ' .. item.id)
  end
  if item then
    self:equip(key, item, inventory, character)
  else
    self:unequip(key, inventory, character)
  end
end
-- Inserts equipment item in the given slot.
-- @param(key : string) slot's key
-- @param(item : table) item's data from database
-- @param(inventory : Inventory) troop's inventory
-- @param(character : Character) battler's character, in case it's during battle (optional)
function EquipSet:equip(key, item, inventory, character)
  local slot = self.slots[key]
  local equip = item.equip
  -- If slot is blocked
  if slot.block and self.slots[slot.block] then
    self:unequip(slot.block, inventory, character)
  end
  -- Unequip slots from the same slot type
  if equip.allSlots then
    key = equip.type .. '1'
    slot = self.slots[key]
    self:unequip(equip.type, inventory, character)
  else
    self:unequip(key, inventory, character)
  end
  for i = 1, #equip.block do
    self:unequip(equip.block[i], inventory, character)
  end
  -- Block slots
  for i = 1, #equip.block do
    self:setBlock(equip.block[i], key)
  end
  if equip.allSlots then
    self:setBlock(equip.type, equip.type)
  end
  slot = self.slots[key]
  self:addStatus(item.equip, character)
  inventory:removeItem(item.id)
  slot.id = item and item.id or -1
  self:updateSlotBonus(key)
end
-- Removes equipment item (if any) from the given slot.
-- @param(key : string) slot's key
-- @param(inventory : Inventory) troop's inventory
-- @param(character : Character) battler's character, in case it's during battle (optional)
function EquipSet:unequip(key, inventory, character)
  if self.types[key] then
    for i = 1, self.types[key].count do
      self:unequip(key .. i, inventory, character)
    end
  else
    local slot = self.slots[key]
    local previousEquip = slot.id
    if previousEquip >= 0 then
      local data = Database.items[previousEquip]
      local equip = data.equip
      self:removeStatus(equip, character)
      inventory:addItem(previousEquip)
      slot.id = -1
      -- Unblock slots
      for i = 1, #equip.block do
        self:setBlock(equip.block[i], nil)
      end
      -- Unblock slots from the same slot type
      if equip.allSlots then
        self:setBlock(equip.type, nil)
      end
      self:updateSlotBonus(key)
    end
  end
end
-- Sets the block of all slots from the given type to hte given value.
-- @param(key : string) the type of slot (includes a number if it's a specific slot)
-- @param(block : string) the name of the slot that it blocking, or nil to unblock
function EquipSet:setBlock(key, block)
  if self.types[key] then
    for i = 1, self.types[key].count do
      local keyi = key .. i
      self.slots[keyi].block = block
    end
  else
    self.slots[key].block = block
  end
end
-- @param(key : string) 
-- @ret(boolean) if the item may be equiped
function EquipSet:canEquip(key, item)
  local slotType = self.types[item.equip.type]
  if slotType.state >= 3 then
    return false
  end
  local currentItem = self:getEquip(key)
  if item == currentItem then
    return true
  end
  local blocks = item.equip.block
  for i = 1, #blocks do
    if not self:canUnequip(blocks[i]) then
      return false
    end
  end
  if item.equip.allSlots then
    if slotType.count > 1 and slotType.state == 2 then
      return false
    end
  end
  local block = self.slots[key].block
  if block and self.slots[block] then
    if not self:canUnequip(block) then
      return false
    end
  end
  return true
end

function EquipSet:canUnequip(key)
  if self.types[key] then
    for i = 1, self.types[key].count do
      if not self:canUnequip(key .. i) then
        return false
      end
    end
    return true
  end
  local currentItem = self:getEquip(key)
  if currentItem then
    local slot = self.types[currentItem.equip.type]
    if slot.state >= 2 then -- Cannot unequip
      return false
    elseif slot.state == 1 then
      for i = 1, slot.count do
        local key2 = currentItem.equip.type .. i
        if key2 ~= key and self:getEquip(key2) then
          return true
        end
      end
      return false
    end
  end
  return true
end

---------------------------------------------------------------------------------------------------
-- Status
---------------------------------------------------------------------------------------------------

-- Adds all equipments' battle status.
-- @param(character : Character) battler's character
function EquipSet:addBattleStatus(character)
  for key, slot in pairs(self.slots) do
    if slot.id >= 0 then
      local item = Database.items[slot.id]
      self:addStatus(item.equip, character, true)
    end
  end
end
-- Adds the equip's status.
-- @param(data : table) item's equip data
-- @param(character : Character) battler's character, in case it's during battle (optional)
-- @param(battle : boolean) true to add battle status, false to add persistent status
function EquipSet:addStatus(data, character, battle)
  local statusList = battle and data.battleStatus or data.status
  for i = 1, #statusList do
    self.battler.statusList:addStatus(statusList[i], nil, character)
  end
end
-- Removes the equip's persistent status.
-- @param(data : table) item's equip data
-- @param(character : Character) battler's character, in case it's during battle (optional)
function EquipSet:removeStatus(data, character)
  for i = 1, #data.status do
    self.battler.statusList:removeStatus(data.status[i], character)
  end
end

---------------------------------------------------------------------------------------------------
-- Bonus
---------------------------------------------------------------------------------------------------

-- Gets an attribute's total bonus given by the equipment.
-- @param(key : string) attribute's key
-- @ret(number) the total additive bonus
-- @ret(number) the total multiplicative bonus
function EquipSet:attBonus(key)
  local add, mul = 0, 0
  for k, slot in pairs(self.bonus) do
    add = add + (slot.attAdd[key] or 0)
    mul = mul + (slot.attMul[key] or 0)
  end
  return add, mul
end
-- Gets an element's total bonus given by the equipment.
-- @param(id : number) element's id
-- @ret(number) the total bonus
function EquipSet:elementBonus(id)
  local e = 0
  for k, slot in pairs(self.bonus) do
    e = e + (slot.elements[id] or 0)
  end
  return e
end

---------------------------------------------------------------------------------------------------
-- Equip Bonus
---------------------------------------------------------------------------------------------------

-- Updates the tables of equipment attribute and element bonus.
-- @param(slot : table) slot data
function EquipSet:updateSlotBonus(key)
  local bonus = self.bonus[key]
  if not self.bonus[key] then
    bonus = {}
    self.bonus[key] = bonus
  end
  local slot = self.slots[key]
  local equip = slot.id >= 0 and Database.items[slot.id].equip
  bonus.attAdd, bonus.attMul = self:equipAttributes(equip)
  bonus.elements = self:equipElements(equip)
end
-- Gets the table of equipment attribute bonus.
-- @param(equip : table) item's equip data
-- @ret(table) additive bonus table
-- @ret(table) multiplicative bonus table
function EquipSet:equipAttributes(equip)
  local add, mul = {}, {}
  if equip and equip.attributes then
    for i = 1, #equip.attributes do
      local bonus = equip.attributes[i]
      add[bonus.key] = (bonus.add or 0)
      mul[bonus.key] = (bonus.mul or 0) / 100
    end
  end
  return add, mul
end
-- Gets the table of equipment element bonus.
-- @param(equip : table) item's equip data
-- @ret(table) bonus array
function EquipSet:equipElements(equip)
  local e = {}
  if equip and equip.elements then
    for i = 1, #equip.elements do
      local bonus = equip.elements[i]
      e[bonus.id] = (bonus.value or 0) / 100
    end
  end
  return e
end

---------------------------------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------------------------------

-- @ret(table) persistent state
function EquipSet:getState()
  return {
    slots = deepCopyTable(self.slots),
    types = deepCopyTable(self.types) }
end

return EquipSet