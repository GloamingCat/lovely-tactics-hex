
--[[===============================================================================================

Array Utilities
---------------------------------------------------------------------------------------------------
General utilities for arrays.

=================================================================================================]]

local deepCopy = util.table.deepCopy
local util = {}

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Gets the index of the given element in the given array.
-- @param(arr : table) the array
-- @param(el : unknown) the element
-- @ret(number) the index of the element if found, nil if not found
function util.indexOf(arr, el)
  for i = 1, #arr do
    if arr[i] == el then
      return i
    end
  end
  return nil
end
-- Creates a new array of given size with all elements starting with the given value.
-- @param(size : number) size of the array
-- @param(value : unknown) initial value of all elements
-- @ret(table) the newly created array
function util.new(size, value)
  local a = {}
  for i = 1, size do
    a[i] = value
  end
  return a
end
-- Creates a shallow copy (only object references) of the given array.
-- @param(array : table) The array with the object references to be copied.
-- @ret(table) The shallow copy of the array.
function util.shallowCopy(array)
  local copy = {}
  util.addAll(copy, array)
  return copy
end
-- Creates a deep copy (also clones items) of the given array.
-- @param(array : table) The array to be cloned.
-- @ret(table) The deep copy of the array.
function util.deepCopy(array)
  local copy = {}
  for i = 1, #array do
    local typ = type(v)
    if typ == 'table' then
      copy[i] = deepCopy(array[i])
    else
      copy[i] = array[i]
    end
  end
  return copy
end
-- Combines an array of arrays into a single array.
-- @param(arrays : table) array of arrays
-- @ret(table) the joined arrays
function util.join(arrays)
  local new = {}
  for i = 1, #arrays do
    local arr = arrays[i]
    util.addAll(new, arr)
  end
  return new
end
-- Inserts all the elements from the second array in the first one.
-- @param(array : table) array to be modified
-- @param(elements : table) array containing the elements to be inserted
function util.addAll(array, elements)
  for i = 1, #elements do
    array[#array + 1] = elements[i]
  end
end

---------------------------------------------------------------------------------------------------
-- Search
---------------------------------------------------------------------------------------------------

-- Searches for an element with the given key.
-- @param(arr : table) Array of table elements.
-- @param(key : string) Key of the element.
-- @ret(table) Elements of the array with the given key (nil if not found).
function util.findByKey(arr, key)
  for i = 1, #arr do
    if arr[i].key == key then
      return arr[i]
    end
  end
end
-- Searches for an element with the given key.
-- @param(arr : table) Array of table elements.
-- @param(name : string) Name of the element.
-- @ret(table) Elements of the array with the given name (nil if not found).
function util.findByName(arr, name)
  for i = 1, #arr do
    if arr[i].name == name then
      return arr[i]
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Array Stats
---------------------------------------------------------------------------------------------------

-- Sums all the elements in a array of numbers (or objects with the + operator).
-- @param(arr : table) array containing the elements
-- @ret(unknown) the sum of all elements
function util.sum(arr)
  local s = 0
  for i = 1, #arr do
    s = s + arr[i]
  end
  return s
end
-- Multiples all the elements in a array of numbers (or objects with the * operator).
-- @param(arr : table) array containing the elements
-- @ret(unknown) the product of all elements
function util.mul(arr)
  local m = 1
  for i = 1, #arr do
    m = m * arr[i]
  end
  return m
end
-- Gets the maximum element from an array of numbers (or objects with the > operator).
-- @param(arr : table) array containing the elements
-- @ret(unknown) the maximum element
function util.max(arr)
  if #arr == 0 then
    return nil
  end
  local m = 1
  for i = 2, #arr do
    if arr[i] > arr[m] then
      m = i
    end
  end
  return arr[m], m
end
-- Gets the mean value from an array of numbers (or objects with + and / operators).
-- @param(arr : table) array containing the elements
-- @ret(unknown) the mean
function util.mean(arr)
  return util.sum(arr) / #arr
end

return util