
--[[===============================================================================================

SaveManager
---------------------------------------------------------------------------------------------------
Responsible for storing and loading game saves.

=================================================================================================]]

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
end

---------------------------------------------------------------------------------------------------
-- Save / Load
---------------------------------------------------------------------------------------------------

-- Gets the total play time of the current save.
function SaveManager:getPlayTime()
  return self.current.playTime + (love.timer.getTime() - self.loadTime)
end
-- Loads the specified save.
-- @param(name : string) file name
function SaveManager:loadSave(name)
  self.loadTime = love.timer.getTime()
  -- TODO: load file
end
-- Stores current save.
function SaveManager:storeSave()
  self.current.playTime = self:getPlayTime()
  -- TODO: store file
  self.loadTime = love.timer.getTime()
end

---------------------------------------------------------------------------------------------------
-- Troop Data
---------------------------------------------------------------------------------------------------

function SaveManager:currentTroop()
  return Database.troops[self.current.playerTroopID]
end

return SaveManager
