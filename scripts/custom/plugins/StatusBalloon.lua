
--[[===============================================================================================

StatusBalloon
---------------------------------------------------------------------------------------------------
The balloon animation to show a battler's status.

=================================================================================================]]

-- Imports
local Animation = require('core/graphics/Animation')
local Balloon = require('custom/animation/Balloon')
local BattleCursor = require('core/battle/BattleCursor')
local CharacterBase = require('core/objects/CharacterBase')
local List = require('core/datastruct/List')
local Sprite = require('core/graphics/Sprite')
local StatusList = require('core/battle/battler/StatusList')
local TroopManager = require('core/battle/TroopManager')

-- Alias
local Image = love.graphics.newImage

-- Parameters
local balloonID = tonumber(args.balloonID)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor. Initializes state and icon animation.
local Balloon_init = Balloon.init
function Balloon:init(...)
  Balloon_init(self, ...)
  self.state = 4
  self.statusIndex = 0
  self.status = {}
  self:initIcon()
  self.sprite:setCenterOffset()
  self:hide()
end
-- Creates the icon animation.
function Balloon:initIcon()
  local sprite = Sprite(FieldManager.renderer)
  local anim = Animation(sprite)
  anim.duration = 30
  self:setIcon(anim)
end
-- Overrides Balloon:update.
-- Considers state 4, when the character has no status.
local Balloon_update = Balloon.update
function Balloon:update()
  if not self.paused and self.state ~= 4 then
    Balloon_update(self)
  end
end
-- Overrides Balloon:onEnd.
-- Checks for status and changes the icon.
local Balloon_onEnd = Balloon.onEnd
function Balloon:onEnd()
  Balloon_onEnd(self)
  if self.state == 1 then -- Show next icon
    self:nextIcon()
  end
end

function Balloon:nextIcon()
  self.statusIndex = math.mod1(self.statusIndex + 1, #self.status)
  local icon = self.status[self.statusIndex]
  local data = Database.animations[icon.id]
  local quad, texture = ResourceManager:loadQuad(data, nil, icon.col, icon.row)
  self.iconAnim.sprite:setTexture(texture)
  self.iconAnim.sprite:setQuad(quad)
  self.iconAnim.sprite:setCenterOffset()
  local x, y, w, h = quad:getViewport()
  self.iconAnim.quadWidth = w
  self.iconAnim.quadHeight = h
end

function Balloon:setIcons(icons)
  self.status = icons
  if #icons > 0 then
    if self.state == 4 then
      self:nextIcon()
      self:show()
      self.state = 0
    end
  else
    self.state = 4
    self.iconAnim:reset()
    self.iconAnim:hide()
    self:reset()
    self:hide()
  end
end

---------------------------------------------------------------------------------------------------
-- StatusList
---------------------------------------------------------------------------------------------------

-- Refreshes icon list.
local StatusList_updateGraphics = StatusList.updateGraphics
function StatusList:updateGraphics(character)
  StatusList_updateGraphics(self, character)
  if character.balloon then
    local icons = self:getIcons()
    character.balloon:setIcons(icons)
  end
end

---------------------------------------------------------------------------------------------------
-- CharacterBase
---------------------------------------------------------------------------------------------------

-- Override.
local CharacterBase_setXYZ = CharacterBase.setXYZ
function CharacterBase:setXYZ(x, y, z)
  CharacterBase_setXYZ(self, x, y, z)
  if self.balloon then
    self.balloon:updatePosition(self)
  end
end
-- Override.
local CharacterBase_update = CharacterBase.update
function CharacterBase:update()
  CharacterBase_update(self)
  if not self.paused and self.balloon then
    self.balloon:update()
  end
end
-- Override.
local CharacterBase_destroy = CharacterBase.destroy
function CharacterBase:destroy()
  CharacterBase_destroy(self)
  if self.balloon then
    self.balloon:destroy()
  end
end

---------------------------------------------------------------------------------------------------
-- TroopManager
---------------------------------------------------------------------------------------------------

-- Override. Creates a balloon for each battle character.
local TroopManager_createBattler = TroopManager.createBattler
function TroopManager:createBattler(character)
  TroopManager_createBattler(self, character)
  if character.battler then
    local balloonAnim = Database.animations[balloonID]
    character.balloon = ResourceManager:loadAnimation(balloonAnim, FieldManager.renderer)
    character.balloon.sprite:setTransformation(balloonAnim.transform)
    local icons = character.battler.statusList:getIcons()
    character.balloon:setIcons(icons)
    character:setPosition(character.position)
  end
end

---------------------------------------------------------------------------------------------------
-- BattleCursor
---------------------------------------------------------------------------------------------------

-- Sets the position to the given tile.
-- @param(tile : ObjectTile) the target tile
local BattleCursor_setTile = BattleCursor.setTile
function BattleCursor:setTile(tile)
  BattleCursor_setTile(self, tile)
  for char in tile.characterList:iterator() do
    if char.balloon and char.balloon.state ~= 4 then
      self:addBalloonHeight(char.balloon)
      break
    end
  end
end
-- Sets the position to the given character.
-- @param(char : Character) the target character
local BattleCursor_setCharacter = BattleCursor.setCharacter
function BattleCursor:setCharacter(char)
  BattleCursor_setCharacter(self, char)
  if char.balloon and char.balloon.state ~= 4 then
    self:addBalloonHeight(char.balloon)
  end
end
-- Translates cursor to above the balloon.
-- @param(balloon : Balloon)
function BattleCursor:addBalloonHeight(balloon)
  local sprite = self.anim.sprite
  local _, by = balloon.sprite:totalBounds()
  sprite:setXYZ(nil, math.min(sprite.position.y, by + 8))
end
