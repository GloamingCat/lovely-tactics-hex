
--[[===============================================================================================

Database
---------------------------------------------------------------------------------------------------
Loads data from the data folder and stores in the Database or Config global tables.

=================================================================================================]]

---------------------------------------------------------------------------------------------------
-- Auxiliar functions
---------------------------------------------------------------------------------------------------

-- Ignores folder nodes and insert data nodes in the array in the position given by data index.
-- @param(children : table) original array of nodes
-- @param(arr : table) final array with the data nodes (creates an empty one if nil)
-- @ret(table) the array with the data nodes 
local function toArray(children, arr)
  arr = arr or {}
  for i = 1, #children do
    local node = children[i]
    if node.data then
      arr[node.data.id] = node.data
      node.data.name = node.name
      if node.data.key then
        arr[node.data.key] = node.data
      end
    else
      toArray(node.children, arr)
    end
  end
  return arr
end
-- Creates alternate keys for the data elements in the given array.
-- Each element must contain a string "key" field.
-- @param(arr : table) array with data element
local function insertKeys(arr)
  for i = 1, #arr do
    local a = arr[i]
    arr[a.key] = a
  end
end
-- Gets the array dis
local function getRootArray(file)
  local root = {}
  local files = love.filesystem.getDirectoryItems('data/')
  for i = 1, #files do
    if files[i]:find(file .. '%w*' .. '%.json') then
      local data = JSON.load('data/' .. files[i])
      util.array.addAll(root, data)
    end
  end
  if #root == 0 then
    assert(data, 'Could not load ' .. file)
  end
  return root
end

---------------------------------------------------------------------------------------------------
-- Database files
---------------------------------------------------------------------------------------------------

Database = {}
local db = {'animations', 'battlers', 'characters', 'classes', 'items', 'obstacles', 'scripts',
  'skills', 'status', 'terrains', 'troops'}
for i = 1, #db do
  local file = db[i]
  local data = getRootArray(file)
  Database[file] = toArray(data)
end

---------------------------------------------------------------------------------------------------
-- Config files
---------------------------------------------------------------------------------------------------

local sys = {'attributes', 'elements', 'regions', 'equipTypes'}
for i = 1, #sys do
  local file = sys[i]
  local data = JSON.load('data/system/' .. file .. '.json')
  Config[file] = data
end
local vars = JSON.load('data/system/variables.json')
Config.variables = toArray(vars)
insertKeys(Config.variables)
insertKeys(Config.attributes)
insertKeys(Config.equipTypes)