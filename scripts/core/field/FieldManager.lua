
--[[===============================================================================================

FieldManager
---------------------------------------------------------------------------------------------------
Responsible for drawing and updating the current field, and also loading and storing fields from 
game's data.

=================================================================================================]]

-- Imports
local List = require('core/datastruct/List')
local Stack = require('core/datastruct/Stack')
local Vector = require('core/math/Vector')
local Renderer = require('core/graphics/Renderer')
local Field = require('core/field/Field')
local Interactable = require('core/objects/Interactable')
local Character = require('core/objects/Character')
local Player = require('core/objects/Player')
local FiberList = require('core/fiber/FiberList')
local FieldCamera = require('core/field/FieldCamera')
local FieldParser = require('core/field/FieldParser')

-- Alias
local mathf = math.field

local FieldManager = class()

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Constructor.
function FieldManager:init()
  self.renderer = nil
  self.currentField = nil
  self.paused = false
  self.blocks = 0
  self.fiberList = FiberList()
end
-- Calls all the update functions.
function FieldManager:update()
  if self.blocks > 0 then
    return
  end
  self.fiberList:update()
  self.currentField:update()
  for object in self.updateList:iterator() do
    object:update()
  end
  self.renderer:update()
end

---------------------------------------------------------------------------------------------------
-- Field Creation (internal use only)
---------------------------------------------------------------------------------------------------

-- Creates field from ID.
-- @param(fieldID : number) the field's ID
function FieldManager:loadField(fieldID)
  if self.currentField ~= nil then
    --self:storePersistentData()
  end
  local fieldData = JSON.load('data/fields/' .. fieldID)
  self.updateList = List()
  self.characterList = List()
  if self.renderer then
    self.renderer:deactivate()
  end
  self.renderer = self:createCamera(fieldData.sizeX, fieldData.sizeY, #fieldData.layers)
  self.currentField = Field(fieldData)
  FieldParser.loadGrid(self.currentField, fieldData.layers)
  self.currentField:mergeLayers(fieldData.layers)
  for tile in self.currentField:gridIterator() do
    tile:createNeighborList()
  end
  collectgarbage('collect')
  return fieldData
end
-- Create new field camera.
-- @param(sizeX : number) the number of tiles in x axis
-- @param(sizeY : number) the number of tiles in y axis
-- @param(layerCount : number) the total number of layers in the field
-- @ret(FieldCamera) newly created camera
function FieldManager:createCamera(sizeX, sizeY, layerCount)
  local mind, maxd = mathf.minDepth(sizeX, sizeY), mathf.maxDepth(sizeX, sizeY)
  local renderer = FieldCamera(sizeX * sizeY * layerCount * 4, mind, maxd, 1)
  renderer:setXYZ(mathf.pixelWidth(sizeX, sizeY) / 2, 0)
  return renderer
end
-- Creates a character representing player.
-- @ret(Player) the newly created player
function FieldManager:createPlayer(t)
  local tile = self.currentField:getObjectTile(t.x, t.y, t.h)
  local player = Player(tile, t.direction)
  return player
end
-- @param(transitions : table) array of field's transitions
function FieldManager:createTransitions(transitions)
  local field = self.currentField
  local function instantiate(transition, minx, maxx, miny, maxy)
    local script = { 
      commands = { {
        name = "moveToField",
        param = transition
      } },
      global = true }
    for x = minx, maxx do
      for y = miny, maxy do
        local tile = field:getObjectTile(x, y, 0)
        if not tile:collidesObstacle(0, 0) then
          local char = { key = '',
            x = x, y = y, h = 0,
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
      instantiate(t, t.min or 1, t.max or w, 1, 1)
    elseif t.side == 'south' then
      instantiate(t, t.min or 1, t.max or w, h, h)
    elseif t.side == 'west' then
      instantiate(t, 1, 1, t.min or 1, t.max or h)
    elseif t.side == 'east' then
      instantiate(t, w, w, t.min or 1, t.max or h)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------------------------------

-- Creates a new Transition table based on player's current position.
-- @ret(table) the transition data
function FieldManager:getPlayerTransition()
  if self.player == nil then
    return { fieldID = self.currentField.id }
  end
  local x, y, h = self.player:getTile():coordinates()
  return {
    tileX = x,
    tileY = y,
    height = h,
    direction = self.player.direction,
    fieldID = self.currentField.id }
end
-- Gets a generic variable of this field.
-- @param(id : number) the ID of the variable
-- @ret(unknown) the currently stored value for this variable
function FieldManager:getVariable(id)
  local persistentData = SaveManager.current.fieldData[id]
  if persistentData.variables then
    return persistentData.variables[id]
  else
    return nil
  end
end
-- Sets a generic variable of this field.
-- @param(id : number) the ID of the variable
-- @param(value : unknown) the content of the variable
function FieldManager:setVariable(id, value)
  if value == nil then
    value = true
  end
  local persistentData = SaveManager.current.fieldData[id]
  persistentData.switches = persistentData.switches or {}
  persistentData.switches[id] = value
end
-- Gets manager's state (returns to a previous field).
-- @ret(table) the table with the state's contents
function FieldManager:getState()
  return {
    field = self.currentField,
    player = self.player,
    renderer = self.renderer,
    updateList = self.updateList,
    characterList = self.characterList,
    fiberList = self.fiberList }
end
-- Sets manager's state (returns to a previous field).
-- @param(state : table) the table with the state's contents
function FieldManager:setState(state)
  self.currentField = state.field
  self.player = state.player
  self.renderer = state.renderer
  self.fiberList = state.fiberList
  self.updateList = state.updateList
  self.characterList = state.updateList
  self.renderer:activate()
end

---------------------------------------------------------------------------------------------------
-- Persistent Data
---------------------------------------------------------------------------------------------------

-- Loads each character's persistent data.
-- @param(id : number) the field id
function FieldManager:loadPersistentData(id)
  local persistentData = SaveManager.current.fieldData[id]
  if persistentData == nil then
    persistentData = {}
    SaveManager.current.fieldData[id] = persistentData
  end
  for char in self.characterList:iterator() do
    char:setPersistentData(persistentData[char.id])
  end
end
-- Stores each character's persistent data.
function FieldManager:storePersistentData()
  local id = self.currentField.id
  local persistentData = SaveManager.current.fieldData[id]
  if persistentData == nil then
    persistentData = {}
    SaveManager.current.fieldData[id] = persistentData
  end
  for char in self.characterList:iterator() do
    persistentData[char.id] = char:getPersistentData()
  end
end
-- Gets current field's persistent data from save.
-- @ret(table) the data table from save
function FieldManager:getPersistentData()
  local id = self.currentField.id
  return SaveManager.current.fieldData[id]
end

---------------------------------------------------------------------------------------------------
-- Field transition
---------------------------------------------------------------------------------------------------

-- Loads a field from file data and replaces current. 
-- The information about the field must be stored in the transition data.
-- The loaded field will the treated as an exploration field.
-- Don't use this function if you just want to move the player to another tile in the same field.
-- @param(transition : table) the transition data
function FieldManager:loadTransition(transition, fromSave)
  local fieldID = transition.fieldID
  local fieldData = self:loadField(fieldID)
  -- Create characters
  for i, char in ipairs(fieldData.characters) do
    if char.charID then
      Character(char)
    else
      Interactable(char)
    end
  end
  self.player = self:createPlayer(transition)
  self.renderer.focusObject = self.player
  --self:loadPersistentData(fieldID)
  -- Create/call start listeners
  local script = self.currentField.startScript
  if script then
    self.fiberList:forkFromScript(script, {fromSave = fromSave})
  end
  for char in self.characterList:iterator() do
    local script = char.startScript
    if script ~= nil then
      local event = {character = char, fromSave = fromSave}
      char:onStart(event)
    end
  end
  self.player.fiberList:fork(self.player.checkFieldInput, self.player)
  self:createTransitions(fieldData.prefs.transitions)
end
-- [COROUTINE] Loads a battle field and waits for the battle to finish.
-- It MUST be called from a fiber in FieldManager's fiber list, or else the fiber will be 
-- lost in the field transition. At the end of the battle, it reloads the previous field.
-- @param(fieldID : number) the field's id
-- @ret(number) the number of the party that won the battle
function FieldManager:loadBattle(fieldID, params)
  local previousState = self:getState()
  self:loadField(fieldID)
  self.player = nil
  BattleManager:setUp(params)
  if self.currentField.startScript then
    local script = self.currentField.startScript
    local fiber = self.fiberList:forkFromScript(script.path, {})
    fiber:execAll()
  end
  collectgarbage('collect')
  local winner, result = BattleManager:runBattle()
  self:setState(previousState)
  previousState = nil
  collectgarbage('collect')
  return winner, result
end

---------------------------------------------------------------------------------------------------
-- Auxiliary Functions
---------------------------------------------------------------------------------------------------

-- Search for a character with the given key
-- @param(key : string) the key of the character
-- @ret(Character) the first character found with the given key (nil if none was found)
function FieldManager:search(key)
  for char in self.characterList:iterator() do
    if char.key == key then
      return char
    end
  end
end
-- Searchs for characters with the given key
-- @param(key : string) the key of the character(s)
-- @ret(List) list of all characters with the given key
function FieldManager:searchAll(key)
  local list = List()
  for char in self.characterList:iterator() do
    if char.key == key then
      list:add(char)
    end
  end
  return list
end
-- Shows field grid GUI.
function FieldManager:showGrid()
  for tile in self.currentField:gridIterator() do
    tile.gui:show()
  end
end
-- Hides field grid GUI.
function FieldManager:hideGrid()
  for tile in self.currentField:gridIterator() do
    tile.gui:hide()
  end
end

return FieldManager
