
local TerrainLayer = require('core/fields/TerrainLayer')
local ObjectLayer = require('core/fields/ObjectLayer')
local max = math.max
local min = math.min

--[[===========================================================================

A FieldBase stores sets of different layers: Terrain, Object,
Character and Region layers.
It must be created from a data file.

=============================================================================]]

local FieldBase = require('core/class'):new()

-- @param(data : table) the data from file
function FieldBase:init(data)
  self.id = data.id
  self.sizeX = data.sizeX
  self.sizeY = data.sizeY
  self.terrainLayers = {}
  self.objectLayers = {}
  if data.prefs.defaultRegion >= 0 then
    self.defaultRegion = data.prefs.defaultRegion
  end
  local minh = 100
  local maxh = 0
  self.tileset = Database.tilesets[data.prefs.tilesetID + 1]
  for i,layerData in ipairs(data.layers) do
    maxh = max(layerData.info.height, maxh)
    minh = min(layerData.info.height, minh)
  end
  for i = minh, maxh do
    self.terrainLayers[i] = {}
    self.objectLayers[i] = ObjectLayer(self.sizeX, self.sizeY, i, self.defaultRegion)
  end
  self.centerX, self.centerY = math.field.pixelCenter(self)
  self.minx, self.miny, self.maxx, self.maxy = math.field.pixelBounds(self)
  if data.prefs.onStart.path ~= nil then
    self.startScript = data.prefs.onStart
  end
end

-- Merges layers' data.
-- @param(layers : table) an array of layer data
function FieldBase:mergeLayers(layers)
  for i,layerData in ipairs(layers) do
    local t = layerData.info.type
    if t == 0 then
      self:addTerrainLayer(layerData)
    elseif t == 1 then
      self:addObstacleLayer(layerData)
    elseif t == 2 then
      self:addCharacterLayer(layerData)
    elseif t == 3 then
      self:addRegionLayer(layerData)
    elseif t == 4 then
      self:addBattleTypeLayer(layerData)
    elseif t == 5 then
      self:addPartyLayer(layerData)
    end
  end
end

-- Creates a new TerrainLayer. 
-- All layers are stored by height.
-- @param(layerData : table) the data from field's file
-- @param(tileset : table) the tileset's data from file
function FieldBase:addTerrainLayer(layerData)
  local list = self.terrainLayers[layerData.info.height]
  local order = #list
  local layer = TerrainLayer(layerData, self.sizeX, self.sizeY, order, self.tileset)
  list[order + 1] = layer
end

-- Merges the obstacle layers. If there's no layer in that height, creates a new one.
-- All layers are stored by height.
-- @param(layerData : table) the data from field's file
function FieldBase:addObstacleLayer(layerData)
  self.objectLayers[layerData.info.height]:mergeObstacles(layerData, self.tileset)
end

-- Merges the character layers. If there's no layer in that height, creates a new one.
-- All layers are stored by height.
-- @param(layerData : table) the data from field's file
function FieldBase:addCharacterLayer(layerData)
  self.objectLayers[layerData.info.height]:mergeCharacters(layerData, self.tileset)
end

-- Merges the region layers. If there's no layer in that height, creates a new one.
-- All layers are stored by height.
-- @param(layerData : table) the data from field's file
function FieldBase:addRegionLayer(layerData)
  self.objectLayers[layerData.info.height]:mergeRegions(layerData, self.tileset)
end

-- Merges the battle tile layers. If there's no layer in that height, creates a new one.
-- All layers are stored by height.
-- @param(layerData : table) the data from field's file
function FieldBase:addBattleTypeLayer(layerData)
  self.objectLayers[layerData.info.height]:mergeBattleTypes(layerData)
end

-- Merges the party layers. If there's no layer in that height, creates a new one.
-- All layers are stored by height.
-- @param(layerData : table) the data from field's file
function FieldBase:addPartyLayer(layerData)
  self.objectLayers[layerData.info.height]:mergeParties(layerData)
end

return FieldBase
