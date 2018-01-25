
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
  local equipment = save and save.equips or battler.data.equipment
  for i = 1, #equipTypes do
    local slot = equipTypes[i]
    for k = 1, slot.count do
      local key = slot.key .. k
      local slotData = equipment and equipment[key] and deepCopyTable(equipment[key]) 
          or { id = -1, state = slot.state }
      self.slots[key] = slotData
      self:updateSlotBonus(slotData)
      if equipment == battler.data.equipment and slotData.id >= 0 then
        local data = Database.items[slotData.id]
        self:addStatus(data.equip)
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Equip / Unequip
---------------------------------------------------------------------------------------------------

-- Gets the ID of the current equip in the given slot.
-- @param(key : string) slot's key
-- @ret(number) the ID of the equip item (-1 if none)
function EquipSet:getEquip(key)
  return self.slots[key].id
end
-- Equips a new item in the given slot.
-- @param(key : string) slot's key
-- @param(item : table) item's data from database
-- @param(inventory : Inventory) troop's inventory
-- @param(character : Character) battler's character, in case it's during battle (optional)
function EquipSet:setEquip(key, item, inventory, character)
  local slot = self.slots[key]
  local previousEquip = slot.id
  -- Remove previous equip
  if previousEquip >= 0 then
    local data = Database.items[previousEquip]
    self:removeStatus(data.equip, character)
    inventory:addItem(previousEquip)
  end
  -- Insert new equip
  if item then
    assert(item.equip, 'Item is not an equipment: ' .. item.id)
    self:addStatus(item.equip, character)
    inventory:removeItem(item.id)
  end
  slot.id = item and item.id or -1
  self:updateSlotBonus(slot)
  -- TODO: check slot rectrictions
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
  for k, slot in pairs(self.slots) do
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
  for k, slot in pairs(self.slots) do
    e = e + (slot.elements[id] or 0)
  end
  return e
end

---------------------------------------------------------------------------------------------------
-- Equip Bonus
---------------------------------------------------------------------------------------------------

-- Updates the tables of equipment attribute and element bonus.
-- @param(slot : table) slot data
function EquipSet:updateSlotBonus(slot)
  local equip = slot.id >= 0 and Database.items[slot.id].equip
  slot.attAdd, slot.attMul = self:equipAttributes(equip)
  slot.elements = self:equipElements(equip)
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
      add[bonus.key] = (bonus.add or 0) / 100
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
  local state = {}
  for i = 1, #equipTypes do
    local slot = equipTypes[i]
    for k = 1, slot.count do
      local key = slot.key .. k
      state[key] = {
        id = self.slots[key].id,
        state = self.slots[key].state }
    end
  end
  return state
end

return EquipSet