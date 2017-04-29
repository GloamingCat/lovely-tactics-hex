
--[[===============================================================================================

GameSave
---------------------------------------------------------------------------------------------------
Stores the game data.

=================================================================================================]]

local GameSave = class()

-- Contructor.
function GameSave:init()
  self.playTime = 0
  self.fieldData = {}
  self.battlers = {}
  local battlers = Database.battlers
  for i = 1, #battlers do 
    if battlers[i].persistent then
      self.battlers[i] = battlers[i]
    end
  end
  local startPos = Config.player.startPos
  self.playerTransition = {
    tileX = startPos.x or 0,
    tileY = startPos.y or 7,
    height = startPos.z or 0,
    fieldID = startPos.fieldID or 0,
    direction = startPos.direction or 270
  }
end

-- Loads persistent data in the database.
function GameSave:load()
  for i, battler in pairs(self.battlers) do
    Database.battlers[i] = battler
  end
end

return GameSave
