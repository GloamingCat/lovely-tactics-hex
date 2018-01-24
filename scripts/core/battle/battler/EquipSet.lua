
--[[===============================================================================================

EquipSet
---------------------------------------------------------------------------------------------------


=================================================================================================]]

-- Alias
local deepCopyTable = util.table.deepCopy

-- Constants
local equipTypes = Config.equipTypes

local EquipSet = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function EquipSet:init(battler, save)
  self.battler = battler
  local equipment = save and save.equips or battler.data.equipment
  for i = 1, #equipTypes do
    local slot = equipTypes[i]
    for k = 1, slot.count do
      local key = slot.key .. k
      local slotData = equipment and equipment[key] and deepCopyTable(equipment[key]) 
          or { id = -1, state = slot.state }
      self[key] = slotData
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Equip / Unequip
---------------------------------------------------------------------------------------------------

function EquipSet:setEquip(key, item, inventory)
  local previousEquip = self[key].id
  self[key].id = item and item.id or -1
  if item then
    inventory:removeItem(item.id)
  end
  if previousEquip >= 0 then
    inventory:addItem(previousEquip)
  end
  -- TODO: status
  -- TODO: check slot rectrictions
end

---------------------------------------------------------------------------------------------------
-- Bonus
---------------------------------------------------------------------------------------------------

function EquipSet:attBonus(key)
  return 0, 0
end

function EquipSet:elementBonus(id)
  return 0
end

---------------------------------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------------------------------

function EquipSet:getState()
  local state = {}
  for i = 1, #equipTypes do
    local slot = equipTypes[i]
    for k = 1, slot.count do
      local key = slot.key .. k
      state[key] = deepCopyTable(self[key])
    end
  end
  return state
end

return EquipSet