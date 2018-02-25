
--[[===============================================================================================

TagMap
---------------------------------------------------------------------------------------------------
Transforms an array of tags into a map.

=================================================================================================]]

local TagMap = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function TagMap:init(tags)
  self.tags = {}
  if tags then
    self:addAll(tags)
  end
end

---------------------------------------------------------------------------------------------------
-- Access
---------------------------------------------------------------------------------------------------

function TagMap:get(name)
  local arr = self.tags[name]
  if arr then
    return arr[1]
  else
    return nil
  end
end

function TagMap:getAll(name)
  return self.tags[name]
end

---------------------------------------------------------------------------------------------------
-- Insertion
---------------------------------------------------------------------------------------------------

function TagMap:add(name, value)
  local arr = self.tags[name]
  if not arr then
    arr = {}
    self.tags[name] = arr
  end
  arr[#arr + 1] = value
  self[name] = self[name] or value
end

function TagMap:addAll(tags)
  for i = 1, #tags do
    local name = tags[i].name
    local value = tags[i].value
    local arr = self.tags[name]
    if not arr then
      arr = {}
      self.tags[name] = arr
    end
    arr[#arr + 1] = value
    self[name] = self[name] or value
  end
end

return TagMap
