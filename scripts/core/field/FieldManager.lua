
--[[===============================================================================================

FieldManager
---------------------------------------------------------------------------------------------------
Responsible for drawing and updating the current field, and also loading and storing fields from 
game's data.

=================================================================================================]]

-- Imports
local FieldCamera = require('core/field/FieldCamera')
local FiberList = require('core/base/fiber/FiberList')
local FieldLoader = require('core/field/FieldLoader')
local List = require('core/base/datastruct/List')
local Player = require('core/objects/Player')
local Renderer = require('core/graphics/Renderer')

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
  if self.blocks > 0 or not self.currentField then
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
  self.updateList = List()
  self.characterList = List()
  if self.renderer then
    self.renderer:deactivate()
  end
  local field, fieldData = FieldLoader.loadField(fieldID)
  self.currentField = field
  self.renderer = self:createCamera(fieldData)
  FieldLoader.mergeLayers(self.currentField, fieldData.layers)
  FieldLoader.loadCharacters(self.currentField, fieldData.characters)
  collectgarbage('collect')
  return fieldData
end
-- Create new field camera.
-- @param(sizeX : number) The number of tiles in x axis.
-- @param(sizeY : number) The number of tiles in y axis.
-- @param(layerCount : number) The total number of layers in the field.
-- @ret(FieldCamera) Newly created camera.
function FieldManager:createCamera(data)
  local h = data.prefs.maxHeight
  local l = 4 * #data.layers.terrain + #data.layers.obstacle + #data.characters
  local mind = mathf.minDepth(data.sizeX, data.sizeY, h)
  local maxd = mathf.maxDepth(data.sizeX, data.sizeY, h)
  local camera = FieldCamera(data.sizeX * data.sizeY * l, mind, maxd, 1)
  camera:setXYZ(mathf.pixelCenter(data.sizeX, data.sizeY))
  return camera
end
-- Creates a character representing player.
-- @ret(Player) the newly created player
function FieldManager:createPlayer(t)
  local tile = self.currentField:getObjectTile(t.x, t.y, t.h)
  return Player(tile, t.direction)
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
  return { x = x, y = y, h = h,
    direction = self.player.direction,
    fieldID = self.currentField.id }
end
-- Gets manager's state (returns to a previous field).
-- @ret(table) the table with the state's contents
function FieldManager:getState()
  return {
    field = self.currentField,
    player = self.player,
    renderer = self.renderer,
    updateList = self.updateList,
    characterList = self.characterList }
end
-- Sets manager's state (returns to a previous field).
-- @param(state : table) the table with the state's contents
function FieldManager:setState(state)
  self.currentField = state.field
  self.player = state.player
  self.renderer = state.renderer
  self.updateList = state.updateList
  self.characterList = state.updateList
  self.renderer:activate()
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
  if self.currentField then
    SaveManager:storeFieldData(self.currentField)
  end
  local fieldData = self:loadField(transition.fieldID)
  self.player = self:createPlayer(transition)
  self.renderer.focusObject = self.player
  self.renderer:setPosition(self.player.position)
  -- Create/call start listeners
  --[[local script = self.currentField.loadScript
  if script then
    self.currentField.fiberList:forkFromScript(script.commands, {fromSave = fromSave})
  end
  for char in self.characterList:iterator() do
    local script = char.loadScript
    if script ~= nil then
      local event = {character = char, fromSave = fromSave}
      char:onStart(event)
    end
  end]]
  self.player.fiberList:fork(self.player.fieldInputLoop, self.player)
  --FieldLoader.createTransitions(self.currentField, fieldData.prefs.transitions)
  if fieldData.prefs.bgm then
    local bgm = fieldData.prefs.bgm
    if AudioManager.BGM == nil or AudioManager.BGM.name ~= bgm.name then
      AudioManager:playBGM(bgm, bgm.time or 0)
    end
  end
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
  if self.currentField.loadScript then
    local script = self.currentField.loadScript
    local fiber = self.fiberList:forkFromScript(script.commands, {})
    fiber:execAll()
  end
  collectgarbage('collect')
  local result = BattleManager:runBattle()
  self:setState(previousState)
  previousState = nil
  collectgarbage('collect')
  return result
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