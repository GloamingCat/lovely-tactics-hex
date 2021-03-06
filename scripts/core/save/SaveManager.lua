
--[[===============================================================================================

SaveManager
---------------------------------------------------------------------------------------------------
Responsible for storing and loading game saves.

=================================================================================================]]

-- Imports
local Serializer = require('core/save/Serializer')
local Troop = require('core/battle/Troop')

-- Alias
local copyTable = util.table.deepCopy
local fileInfo = love.filesystem.getInfo
local now = love.timer.getTime

local SaveManager = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor. 
function SaveManager:init()
  self.current = nil
  if fileInfo('saves.json') then
    self.saves = Serializer.load('saves.json')
  else
    self.saves = {}
  end
  if not fileInfo('saves/') then
    love.filesystem.createDirectory('saves/')
  end
  self.maxSaves = 3
  self.playTime = 0
  self:loadConfig()
end

---------------------------------------------------------------------------------------------------
-- New Data
---------------------------------------------------------------------------------------------------

-- Creates a new save.
-- ret(table) A brand new save table.
function SaveManager:newSave()
  local save = {}
  save.playTime = 0
  save.vars = {} -- Global vars
  save.fields = {} -- Field data
  save.troops = {} -- Initial party
  --save.troops[Config.troop.initialTroopID .. ''] = Troop():getState()
  save.playerTroopID = Config.troop.initialTroopID
  local startPos = Config.player.startPos
  save.playerTransition = {
    x = startPos.x or 1,
    y = startPos.y or 1,
    h = startPos.h or 0,
    direction = startPos.direction or 270,
    fieldID = startPos.fieldID or 0 }
  save.screenColor = { 
    red = 1, 
    green =1, 
    blue = 1, 
    alpha = 0 }
  return save
end
-- Creates default config file.
function SaveManager:newConfig()
  local conf = {}
  conf.volumeBGM = 100
  conf.volumeSFX = 100
  conf.windowScroll = 50
  conf.fieldScroll = 50
  conf.autoDash = false
  conf.wasd = false
  conf.keyMap = copyTable(KeyMap)
  conf.useMouse = true
  conf.resolution = 2
  return conf
end

---------------------------------------------------------------------------------------------------
-- Current Data
---------------------------------------------------------------------------------------------------

-- Creates a save table for the current game state.
-- @ret(table) Initial save.
function SaveManager:currentSaveData()
  local save = {}
  save.playTime = GameManager:currentPlayTime()
  save.vars = copyTable(GameManager.vars)
  save.fields = copyTable(FieldManager.fieldData)
  save.troops = copyTable(TroopManager.troopData)
  save.playerTroopID = TroopManager.playerTroopID
  save.playerTransition = FieldManager:getPlayerTransition()
  return save
end
-- Creates a save table for the current settings.
-- @ret(table) Initial settings.
function SaveManager:currentConfigData()
  local conf = {}
  conf.volumeBGM = AudioManager.volumeBGM
  conf.volumeSFX = AudioManager.volumeSFX
  conf.windowScroll = GUIManager.windowScroll
  conf.fieldScroll = GUIManager.fieldScroll
  conf.autoDash = InputManager.autoDash
  conf.wasd = InputManager.wasd
  conf.keyMap = { main = copyTable(InputManager.mainMap), alt = copyTable(InputManager.altMap) }
  conf.useMouse = InputManager.mouseEnabled
  conf.resolution = ScreenManager.mode
  return conf
end

---------------------------------------------------------------------------------------------------
-- Load
---------------------------------------------------------------------------------------------------

-- Loads the specified save.
-- @param(file : string) File name. If nil, a new save is created.
function SaveManager:loadSave(file)
  if file == nil then
    self.current = self:newSave()
  elseif fileInfo('saves/' .. file .. '.save') then
    self.current = Serializer.load('saves/' .. file .. '.save')
  else
    print('No such save file: ' .. file .. '.save')
    self.current = self:newSave()
  end
  self.loadTime = now()
end
-- Load config file. If 
function SaveManager:loadConfig()
  if fileInfo('config.json') then
    self.config = Serializer.load('config.json')
  else
    self.config = self:newConfig()
  end
end

---------------------------------------------------------------------------------------------------
-- Save
---------------------------------------------------------------------------------------------------

-- Gets the header of the save.
-- @param(save : table) The save, uses the current save if nil.
-- @ret(table) Header of the save.
function SaveManager:getHeader(save)
  save = save or self.current
  local troop = save.troops[self.current.playerTroopID .. ''] or Troop()
  local members = {}
  for i = 1, #troop.members do
    if troop.members[i].list == 0 then
      members[#members + 1] = troop.members[i].charID
    end
  end
  return { members = members,
    playTime = save.playTime,
    money = troop.money,
    location = FieldManager.currentField.name }
end
-- Stores current save.
-- @param(name : string) File name.
function SaveManager:storeSave(file, data)
  self.current = data or self:currentSaveData()
  self.current.playTime = GameManager:currentPlayTime()
  self.current.playerTransition = FieldManager:getPlayerTransition()
  self.saves[file] = self:getHeader(self.current)
  Serializer.store('saves/' .. file .. '.save', self.current)
  Serializer.store('saves.json', self.saves)
  self.loadTime = now()
end
-- Stores config file.
function SaveManager:storeConfig(config)
  self.config = config or self:currentConfigData()
  Serializer.store('config.json', self.config)
end

return SaveManager
