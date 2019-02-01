
--[[===============================================================================================

FieldLoader
---------------------------------------------------------------------------------------------------
Loads and prepares field from file data.

=================================================================================================]]

-- Imports
local Character = require('core/objects/Character')
local Field = require('core/field/Field')
local Interactable = require('core/objects/Interactable')

local FieldLoader = {}

---------------------------------------------------------------------------------------------------
-- Parse
---------------------------------------------------------------------------------------------------

-- @param(fieldData : table) the field's data from file
-- @ret(Field)
function FieldLoader.loadField(fieldData)
  local field = Field(fieldData)
  local ids = FieldLoader.getIDs(field.id)
  local layerData = fieldData.layers
  for l = 1, #layerData do
    local grid = {}
    for i = 1, field.sizeX do
      grid[i] = {}
      for j = 1, field.sizeY do
        local k = (l - 1) * field.sizeX * field.sizeY + (j - 1) * field.sizeX + i
        grid[i][j] = ids[k]
      end
    end
    layerData[l].grid = grid
  end
  return field
end
-- @param(fieldID : number) the ID of the field
-- @ret(table) field's layers IDs in a single array
function FieldLoader.getIDs(fieldID)
  local inputstr = love.filesystem.read('data/fields/' .. fieldID .. '.map')
  local t = string.split(inputstr, '%s')
  for i = 1, #t do
    t[i] = tonumber(t[i])
  end
  return t
end

---------------------------------------------------------------------------------------------------
-- Character
---------------------------------------------------------------------------------------------------

function FieldLoader.loadCharacters(field, characters)
  local persistentData = SaveManager:getFieldData(field.id)
  -- Create characters
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
-- Layers
---------------------------------------------------------------------------------------------------

-- Merges layers' data.
-- @param(layers : table) an array of layer data
function FieldLoader.mergeLayers(field, layers)
  local terrains = 0
  for i,layerData in ipairs(layers) do
    if layerData.type == 0 then
      terrains = terrains + 1
    end
  end
  for i,layerData in ipairs(layers) do
    local t = layerData.type
    if t == 0 then
      -- Terrain
      field:addTerrainLayer(layerData, terrains)
    elseif t == 1 then
      -- Obstacle
      field.objectLayers[layerData.height]:mergeObstacles(layerData)
    elseif t == 2 then
      -- Region
      field.objectLayers[layerData.height]:mergeRegions(layerData)
    elseif t == 3 then
      -- Party
      field.objectLayers[layerData.height]:setParties(layerData)
    end
  end
  for tile in field:gridIterator() do
    tile:createNeighborList()
  end
end

---------------------------------------------------------------------------------------------------
-- Field Transitions
---------------------------------------------------------------------------------------------------

-- @param(transitions : table) array of field's transitions
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