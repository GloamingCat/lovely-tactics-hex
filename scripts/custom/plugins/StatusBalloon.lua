
--[[===============================================================================================

StatusBalloon
---------------------------------------------------------------------------------------------------
The balloon animation to show a battler's status.

=================================================================================================]]

-- Imports
local Animation = require('core/graphics/Animation')
local Balloon = require('custom/animation/Balloon')
local CharacterBase = require('core/objects/CharacterBase')
local List = require('core/datastruct/List')
local Sprite = require('core/graphics/Sprite')
local StatusList = require('core/battle/battler/StatusList')
local TroopManager = require('core/battle/TroopManager')

-- Alias
local Image = love.graphics.newImage

-- Parameters
local balloonID = args.balloonID

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor. Initializes state and icon animation.
local Balloon_init = Balloon.init
function Balloon:init(...)
  Balloon_init(self, ...)
  self.state = 4
  self.statusIndex = 0
  self:initIcon()
  self.status = List()
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

---------------------------------------------------------------------------------------------------
-- Balloon
---------------------------------------------------------------------------------------------------

-- Adds a new status icon.
function Balloon:addIcon(s)
  if not self.status:indexOf(s) then
    self.status:add(s)
  end
  if self.state == 4 then
    self:show()
    self.state = 0
  end
end
-- Removes status icon.
function Balloon:removeIcon(s)
  local i = self.status:indexOf(s)
  self.status:remove(i)
  if self.status:isEmpty() then
    self:reset()
    self:hide()
    self.iconAnim:reset()
    self.iconAnim:hide()
    self.state = 4
  elseif self.statusIndex > i then
    self.statusIndex = self.statusIndex - 1
  end
end

---------------------------------------------------------------------------------------------------
-- Update
---------------------------------------------------------------------------------------------------

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
  if self.state == 3 then
    self.statusIndex = math.mod1(self.statusIndex + 1, #self.status)
  elseif self.state == 1 then
    self.statusIndex = math.mod1(self.statusIndex, #self.status)
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
end

---------------------------------------------------------------------------------------------------
-- StatusList
---------------------------------------------------------------------------------------------------

-- Add status icon to balloon.
local StatusList_addStatus = StatusList.addStatus
function StatusList:addStatus(s, character)
  s = StatusList_addStatus(self, s)
  if character and s and not s.data.cumulative and character.balloon then
    character.balloon:addIcon(s.data.icon)
  end
  return s
end
-- Remove status icon from balloon.
local StatusList_remove = StatusList.removeStatus
function StatusList:removeStatus(s, character)
  s = StatusList_remove(self, s)
  if character and s and character.balloon then
    character.balloon:removeIcon(s.data.icon)
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

-- Override.
local TroopManager_createBattler = TroopManager.createBattler
function TroopManager:createBattler(character)
  TroopManager_createBattler(self, character)
  if character.battler then
    local balloonAnim = Database.animations[balloonID]
    character.balloon = ResourceManager:loadAnimation(balloonAnim, FieldManager.renderer)
    character.balloon.sprite:setTransformation(balloonAnim.transform)
    character:setPosition(character.position)
  end
end
