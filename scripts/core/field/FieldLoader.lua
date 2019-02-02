
--[[===============================================================================================

FieldLoader
---------------------------------------------------------------------------------------------------
Loads and prepares field from file data.

=================================================================================================]]

-- Imports
local Character = require('core/objects/Character')
local Field = require('core/field/Field')
local Interactable = require('core/objects/Interactable')
local Serializer = require('core/base/save/Serializer')
local TagMap = require('core/base/datastruct/TagMap')
local TerrainLayer = require('core/field/TerrainLayer')

local FieldLoader = {}

---------------------------------------------------------------------------------------------------
-- File
---------------------------------------------------------------------------------------------------

-- Loads the field of the given ID.
-- @param(id : number) Field's ID.
-- @ret(Field) New empty field.
-- @ret(table) Field file data.
function FieldLoader.loadField(id)
  local data = Serializer.load('data/fields/' .. id .. '.json')
  local field = Field(data.id, data.prefs.name, data.sizeX, data.sizeY, data.prefs.maxHeight)
  field.persistent = data.prefs.persistent
  field.tags = TagMap(data.prefs.tags)
  -- Script
  local script = data.prefs.loadScript
  if script and script.name ~= '' then
    field.loadScript = script
  end
  -- Battle info
  field.playerParty = data.playerParty
  field.parties = data.parties
  -- Default region
  local defaultRegion = data.prefs.defaultRegion
  if defaultRegion and defaultRegion >= 0 then
    for i = 0, data.pregs.maxHeight do
      local layer = field.objectLayers[i]
      for i = 1, data.sizeX do
        for j = 1, data.sizeY do
          layer.grid[i][j].regionList:add(defaultRegion)
        end
      end
    end
  end
  return field, data
end

---------------------------------------------------------------------------------------------------
-- Layers
---------------------------------------------------------------------------------------------------

-- Merges layers' data.
-- @param(field : Field) Current field.
-- @param(layers : table) Terrain, obstacle and region layer sets.
function FieldLoader.mergeLayers(field, layers)
  local depthOffset = #layers.terrain
  for i, layerData in ipairs(layers.terrain) do
    local list = field.terrainLayers[layerData.info.height]
    assert(list, "Terrain layers out of height limits: " .. layerData.info.height)
    local order = #list
    local layer = TerrainLayer(layerData, field.sizeX, field.sizeY, depthOffset - order + 1)
    list[order + 1] = layer
  end
  for i, layerData in ipairs(layers.obstacle) do
    field.objectLayers[layerData.info.height]:mergeObstacles(layerData)
  end
  for i, layerData in ipairs(layers.region) do
    field.objectLayers[layerData.info.height]:mergeRegions(layerData)
  end
  for tile in field:gridIterator() do
    tile:createNeighborList()
  end
end

---------------------------------------------------------------------------------------------------
-- Character
---------------------------------------------------------------------------------------------------

-- Creates field's characters.
-- @param(field : Field) Current field.
-- @param(characters : table) Array of character instances.
function FieldLoader.loadCharacters(field, characters)
  local persistentData = SaveManager:getFieldData(field.id)
  for i, char in ipairs(characters) do
    local save = persistentData.chars[char.key]
    if not (save and save.deleted) then
      if save and save.charID or char.charID then
        Character(char, save)
      else
        Interactable(char, save)
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Field Transitions
---------------------------------------------------------------------------------------------------

-- Creates interactables for field's transitions.
-- @param(field : Field) Current field.
-- @param(transitions : table) Array of field's transitions.
function FieldLoader.createTransitions(field, transitions)
  local function instantiate(transition, minx, maxx, miny, maxy, h)
    local script = { 
      commands = { {
        name = "moveToField",
        param = transition
      } },
      global = true }
    for x = minx, maxx do
      for y = miny, maxy do
        local tile = field:getObjectTile(x, y, h or 1)
        if not tile:collidesObstacle(0, 0) then
          local char = { key = 'Transition',
            x = x, y = y, h = h or 1,
            collideScript = script }
          Interactable(char)
        end
      end
    end
  end
  local w, h = field.sizeX, field.sizeY
  for i = 1, #transitions do
    local t = transitions[i]
    if t.side == 'north' then
      instantiate(t, t.min or 1, t.max or w, 1, 1, t.height)
    elseif t.side == 'south' then
      instantiate(t, t.min or 1, t.max or w, h, h, t.height)
    elseif t.side == 'west' then
      instantiate(t, 1, 1, t.min or 1, t.max or h, t.height)
    elseif t.side == 'east' then
      instantiate(t, w, w, t.min or 1, t.max or h, t.height)
    end
  end
end

return FieldLoader