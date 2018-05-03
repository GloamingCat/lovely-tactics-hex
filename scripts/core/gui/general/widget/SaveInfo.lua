
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
  local iconSize = 20
  topLeft.x = topLeft.x + 2
  topLeft.y = topLeft.y + 1
  topLeft.z = topLeft.z - 2
  
  local small = Fonts.gui_small
  local tiny = Fonts.gui_tiny
  local medium = Fonts.medium
  
  if save then
    -- Name
    local txtName = SimpleText(Vocab.saveName .. ' ' .. file, topLeft, w, 'left', small)
    -- PlayTime
    local topRight = Vector(w - iconSize, topLeft.y, topLeft.z)
    local iconTime = ResourceManager:loadIcon(Config.icons.time, GUIManager.renderer)
    local imgTime = SimpleImage(iconTime, topRight:coordinates())
    local txtTime = SimpleText(string.time(save.playTime), topLeft, w - iconSize, 'right', small)
    -- Location
    local middleLeft = Vector(topLeft.x + iconSize, topLeft.y + 15, topLeft.z)
    local txtLocal = SimpleText(save.location, middleLeft, w - iconSize, 'left', small)
    -- Gold
    local txtGold = SimpleText(save.gold .. '', middleLeft, w - iconSize, 'right', small)
    -- Chars
    local icons = {}
    for i = 1, #save.members do
      local char = Database.characters[save.members[i]]
      print(char.name)
    end
    
    self.content = { txtName, txtTime, imgTime, txtLocal, txtGold }
  else
    local txtName = SimpleText(Vocab.noSave, topLeft, rw, 'left', medium)
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