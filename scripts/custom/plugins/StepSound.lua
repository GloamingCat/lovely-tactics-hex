
--[[===============================================================================================

StepSound
---------------------------------------------------------------------------------------------------
Plays a SFX when player is walking.

=================================================================================================]]

-- Imports
local Player = require('core/objects/Player')
local TerrainTile = require('core/field/TerrainTile')

-- Alias
local rand = love.math.random

-- Args
local freq = tonumber(args.frequency)
local varPitch = tonumber(args.varPitch) or 0
local varVolume = tonumber(args.varVolume) or 0
local varFreq = tonumber(args.varFreq) or 0

---------------------------------------------------------------------------------------------------
-- Terrain
---------------------------------------------------------------------------------------------------

-- Override.
-- Creates sound table from tags.
local TerrainTile_setTerrain = TerrainTile.setTerrain
function TerrainTile:setTerrain(id)
  TerrainTile_setTerrain(self, id)
  if self.tags.sound then
    self.sound = { name = self.tags.sound,
      pitch = self.tags.pitch or 100,
      volume = self.tags.volume or 100 }
  else
    self.sound = nil
  end
end

---------------------------------------------------------------------------------------------------
-- Player
---------------------------------------------------------------------------------------------------

-- Gets sound of the terrain the player is standing over.
-- @ret(table) SFX table or nil.
function Player:getStepSound()
  local t = self:getTile()
  local layers = FieldManager.currentField.terrainLayers[t.layer.height]
  for i = #layers, 1, -1 do
    local tile = layers[i].grid[t.x][t.y]
    if tile.data then
      return tile.sound
    end
  end
end
-- Override.
-- Plays sound per frame.
local Player_update = Player.update
function Player:update()
  Player_update(self)
  if self:moving() then
    self.stepCount = (self.stepCount or 0) + self.speed / Config.player.walkSpeed
    if self.stepCount > freq then
      local sound = self:getStepSound()
      if sound then
        local pitch = sound.pitch * (rand() * varPitch * 2 - varPitch + 1)
        local volume = sound.volume * (rand() * varVolume * 2 - varVolume + 1)
        if sound then
          AudioManager:playSFX({name = sound.name, pitch = pitch, volume = volume})
        end
      end
      self.stepCount = self.stepCount - freq * (rand() * varFreq * 2 - varFreq + 1)
    end
  end
end