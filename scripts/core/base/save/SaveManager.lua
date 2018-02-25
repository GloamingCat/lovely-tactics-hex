
--[[===============================================================================================

SaveManager
---------------------------------------------------------------------------------------------------
Responsible for storing and loading game saves.

=================================================================================================]]

-- Imports
local Serializer = require('core/base/save/Serializer')

-- Alias
local copyTable = util.table.deepCopy
local now = love.timer.getTime

local SaveManager = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor. 
function SaveManager:init()
  self.current = nil
end
-- Loads a new save.
function SaveManager:newSave()
  local save = {}
  save.playTime = 0
  -- Global vars
  save.vars = {}
  -- Field data
  save.fields = {}
  -- Initial party
  save.troops = {}
  save.playerTroopID = Config.troop.initial
  -- Initial position
  local startPos = Config.player.startPos
  save.playerTransition = {
    x = startPos.x or 1,
    y = startPos.y or 1,
    h = startPos.h or 0,
    direction = startPos.direction or 270,
    fieldID = startPos.fieldID or 0 }
  self.current = save
  self.loadTime = now()
  FieldManager:loadTransition(save.playerTransition)
end

---------------------------------------------------------------------------------------------------
-- Field Data
---------------------------------------------------------------------------------------------------

-- Gets the persistent data of a field.
-- @param(id : number) Field's ID.
-- @ret(table) The data table.
function SaveManager:getFieldData(id)
  id = id .. ''
  local persistentData = self.current.fields[id]
  if persistentData == nil then
    persistentData = { chars = {}, vars = {} }
    self.current.fields[id] = persistentData
  end
  return persistentData
end
-- Stores current field's information in the save data table.
-- @param(field : Field) Field to store (current field by default).
function SaveManager:storeFieldData(field)
  field = field or FieldManager.currentField
  if field.prefs.persistent then
    local persistentData = self:getFieldData(field.id)
    for char in FieldManager.characterList:iterator() do
      if char.persistent then
        persistentData.chars[char.key] = char:getPersistentData()
      end
    end
    persistentData.vars = copyTable(field.vars)
  end
end
-- Stores a character's information in the save data table.
-- @param(fieldID : number) The ID of the character's field.
-- @param(char : Character) Character to store.
function SaveManager:storeCharData(fieldID, char)
  local persistentData = self:getFieldData(fieldID)
  persistentData.chars[char.key] = char:getPersistentData()
end

---------------------------------------------------------------------------------------------------
-- Save / Load
---------------------------------------------------------------------------------------------------

-- Gets the total play time of the current save.
function SaveManager:getPlayTime()
  return self.current.playTime + (now() - self.loadTime)
end
-- Loads the specified save.
-- @param(name : string) File name.
function SaveManager:loadSave(name)
  if love.filesystem.exists(name .. '.save') then
    self.current = Serializer.load(name .. '.save')
    self.loadTime = now()
    FieldManager:loadTransition(self.current.playerTransition)
    print('Loaded game.')
  else
    print('No such save file: ' .. name .. '.save')
  end
end
-- Stores current save.
function SaveManager:storeSave(name)
  self.current.playTime = self:getPlayTime()
  self.current.playerTransition = FieldManager:getPlayerTransition()
  self:storeFieldData()
  Serializer.store(name .. '.save', self.current)
  self.loadTime = now()
  print('Saved game.')
end

return SaveManager
