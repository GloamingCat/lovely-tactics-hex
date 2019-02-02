
--[[===============================================================================================

SaveInfo
---------------------------------------------------------------------------------------------------
A container for a battler's main information.

=================================================================================================]]

-- Imports
local IconList = require('core/gui/general/widget/IconList')
local SimpleImage = require('core/gui/widget/SimpleImage')
local SimpleText = require('core/gui/widget/SimpleText')
local Vector = require('core/math/Vector')

-- Constants
local maxMembers = Config.troop.maxMembers

local SaveInfo = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(file : string)
-- @param(w : number) width of the container
-- @param(h : number) height of the container
-- @param(topLeft : Vector) the position of the top left corner of the container
function SaveInfo:init(file, w, h, topLeft)
  local save = SaveManager.saves[file]
  self.file = file
  
  topLeft = topLeft and topLeft:clone() or Vector(0, 0, 0)
  local margin = 4
  topLeft.x = topLeft.x + 2
  topLeft.y = topLeft.y
  topLeft.z = topLeft.z - 2
  
  local small = Fonts.gui_small
  local tiny = Fonts.gui_tiny
  local medium = Fonts.medium
  
  if save then
    -- PlayTime
    local topRight = Vector(topLeft.x, topLeft.y + 3, topLeft.z)
    local txtTime = SimpleText(string.time(save.playTime), topRight, w, 'right', small)
    -- Gold
    local middleLeft = Vector(topLeft.x, topLeft.y + 13, topLeft.z)
    local txtGold = SimpleText(save.money .. ' ' .. Vocab.g, middleLeft, w , 'right', small)
    -- Chars
    local icons = {}
    for i = 1, maxMembers do
      if save.members[i] then
        local char = Database.characters[save.members[i]]
        local icon = {
          id = char.animations.default.Idle,
          col = 0, row = 7 }
        local sprite = ResourceManager:loadIcon(icon, GUIManager.renderer)
        sprite:applyTransformation(char.transform)
        sprite:setCenterOffset()
        icons[i] = sprite
      else
        icons[i] = false
      end
    end
    local iconList = IconList(Vector(topLeft.x + 10, topLeft.y + 12), w, 20, 20, 20)
    iconList.iconWidth = 18
    iconList.iconHeight = 18
    iconList:setSprites(icons)
    -- Location
    local bottomLeft = Vector(middleLeft.x, middleLeft.y + 10, middleLeft.z)
    local txtLocal = SimpleText(save.location, bottomLeft, w, 'left', small)

    self.content = { txtTime, txtLocal, txtGold, iconList }
  else
    local txtName = SimpleText(Vocab.noSave, topLeft, w, 'left', medium)
    txtName.sprite.alignX = 'center'
    txtName.sprite.alignY = 'center'
    txtName.sprite.maxHeight = h
    self.content = { txtName }
  end
end

---------------------------------------------------------------------------------------------------
-- Widget
---------------------------------------------------------------------------------------------------

-- Sets image position.
function SaveInfo:updatePosition(pos)
  for i = 1, #self.content do
    self.content[i]:updatePosition(pos)
  end
end
-- Shows image.
function SaveInfo:show()
  for i = 1, #self.content do
    self.content[i]:show()
  end
end
-- Hides image.
function SaveInfo:hide()
  for i = 1, #self.content do
    self.content[i]:hide()
  end
end
-- Destroys sprite.
function SaveInfo:destroy()
  for i = 1, #self.content do
    self.content[i]:destroy()
  end
end

return SaveInfo