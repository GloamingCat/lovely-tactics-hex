
--[[===============================================================================================

Database
---------------------------------------------------------------------------------------------------
Loads data from the data folder and stores in the Database or Config global tables.

=================================================================================================]]

-- Imports
local Serializer = require('core/save/Serializer')
local TagMap = require('core/datastruct/TagMap')

local Database = {}

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
      arr[node.id] = node.data
      node.data.id = node.id
    end
    toArray(node.children, arr)
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
-- Unifies all data files in a single array.
-- @param(file : string) Database file name.
-- @ret(table) Array of data.
local function getRootArray(file)
  local root = {}
  local files = love.filesystem.getDirectoryItems('data/')
  local data = nil
  for i = 1, #files do
    if files[i]:find(file .. '%w*' .. '%.json') then
      data = Serializer.load('data/' .. files[i])
      util.array.addAll(root, data)
    end
  end
  assert(#root > 0 or data, 'Could not load ' .. file)
  return root
end

---------------------------------------------------------------------------------------------------
-- Database files
---------------------------------------------------------------------------------------------------

local db = {'animations', 'battlers', 'characters', 'classes', 'items', 'obstacles',
  'skills', 'status', 'terrains', 'troops'}
for i = 1, #db do
  local file = db[i]
  local data = getRootArray(file)
  Database[file] = toArray(data)
end

---------------------------------------------------------------------------------------------------
-- Config files
---------------------------------------------------------------------------------------------------

local sys = {'attributes', 'constants', 'elements', 'regions', 'equipTypes', 'plugins'}
for i = 1, #sys do
  local file = sys[i]
  local data = Serializer.load('data/system/' .. file .. '.json')
  Config[file] = data
end
local anim = Config.animations
Config.animations = {}
for i = 1, #anim do
  Config.animations[anim[i].name] = anim[i].id
end
local icons = Config.icons
Config.icons = {}
for i = 1, #icons do
  Config.icons[icons[i].name] = icons[i]
end
insertKeys(Config.constants)
insertKeys(Config.attributes)
insertKeys(Config.equipTypes)

---------------------------------------------------------------------------------------------------
-- Cache
---------------------------------------------------------------------------------------------------

local PatternCache = {}
local TimingCache = {}
local TagMapCache = {}
local emptyMap = TagMap()

-- Gets the array of indexes for a given string.
-- @param(pattern : string) Numbers separated by spaces.
-- @param(cols : number) Number of columns. Used if pattern is empty.
-- @ret(table) Array of numbers.
function Database:loadPattern(pattern, cols)
  if pattern and pattern ~= '' then
    local arr = PatternCache[pattern]
    if not arr then
      arr = pattern:trim():split('%s')
      for i = 1, #arr do
        arr[i] = tonumber(arr[i])
      end
      PatternCache[pattern] = arr
    end
    return arr
  else
    local arr = PatternCache[cols]
    if not arr then
      arr = {}
      for i = 1, cols do
        arr[i] = i - 1
      end
      PatternCache[cols] = arr
    end
    return arr
  end
end
-- Gets the array of animation frame times for a given string and animation length.
-- @param(duration : string) Total duration of animation or sequence of duration of each frame.
-- @param(size : number) Number of frames (animation length).
-- @ret(table) Array of numbers.
function Database:loadDuration(durationstr, size)
  if durationstr == '' then
    return nil
  end
  local key = durationstr .. '.' .. size
  local arr = TimingCache[key]
  if not arr then
    arr = durationstr:trim():split('%s')
    if #arr < size then
      local duration = tonumber(arr[1])
      duration = duration / size
      for i = 1, size do
        arr[i] = duration
      end
    else
      for i = 1, size do
        arr[i] = tonumber(arr[i])
      end
    end
    TimingCache[key] = arr
  end
  return arr
end
-- Gets the map of tags of the given tag array.
-- @param(tags : table) Array of {key, value} entries.
-- @ret(TagMap) The map with the given entries.
function Database:loadTags(tags)
  if tags == nil then
    return emptyMap
  end
  local map = TagMapCache[tags]
  if not map then
    map = TagMap(tags)
    TagMapCache[tags] = map
  end
  return map
end
-- Clears data cache.
function Database:clearCache()
  for k in pairs(PatternCache) do
    PatternCache[k] = nil
  end
  for k in pairs(TimingCache) do
    TimingCache[k] = nil
  end
  for k in pairs(TagMapCache) do
    TagMapCache[k] = nil
  end
end

return Database