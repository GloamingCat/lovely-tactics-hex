
--[[===============================================================================================

StepSound
---------------------------------------------------------------------------------------------------
Plays a SFX when player is walking. The sound played is defined by the terrain, in the tag list.

-- Terrain parameters:
The <sound> tag defines the path of the sound from the "audio/" folder.
The <pitch> and <volume> tags define the base pitch and volume of the sound respectively.

-- Plugin parameters:
The sounds are played in a frequence of 1 each <freq> frames.
The <freq> value may be modified randomly by adding a value between <varFreq> and -<varFreq>.
The pitch and volume of the sound may be modified the same way with <varPitch> and <varVolume>
respectively.

=================================================================================================]]

-- Imports
local Player = require('core/objects/Player')
local TerrainTile = require('core/field/TerrainTile')

-- Alias
local rand = love.math.random

-- Parameters
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
      pitch = tonumber(self.tags.pitch) or 100,
      volume = tonumber(self.tags.volume) or 100 }
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
  local i, j, h = self:tileCoordinates()
  local layers = FieldManager.currentField.terrainLayers[h]
  for l = #layers, 1, -1 do
    local tile = layers[l].grid[i][j]
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
