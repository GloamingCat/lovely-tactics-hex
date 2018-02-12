
--[[===============================================================================================

BattlerWindow
---------------------------------------------------------------------------------------------------
Window that shows on each character in the VisualizeAction.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local Sprite = require('core/graphics/Sprite')
local Window = require('core/gui/Window')
local SimpleText = require('core/gui/widget/SimpleText')
local SimpleImage = require('core/gui/widget/SimpleImage')

-- Alias
local round = math.round
local max = math.max

-- Constants
local attConfig = Config.attributes
local font = Fonts.gui_small

local BattlerWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(character : Character) the character of the battler to be shown
function BattlerWindow:init(GUI)
  local primary = {}
  local secondary = {}
  for i = 1, #attConfig do
    if attConfig[i].visibility == 1 then
      primary[#primary + 1] = attConfig[i]
    elseif attConfig[i].visibility == 2 then
      secondary[#secondary + 1] = attConfig[i]
    end
  end
  self.primary, self.secondary = primary, secondary
  local hsw = round(ScreenManager.width * 3 / 4)
  local hsh = max(#primary, #secondary) * 10 + 15 + 2 * self:vPadding()
  local margin = 80
  Window.init(self, GUI, hsw, hsh)
end
-- Overrides Window:createContent.
function BattlerWindow:createContent(width, height)
  Window.createContent(self, width, height)
  -- Portrait
  self.portrait = SimpleImage(nil, self:hPadding() - self.width / 2, self:vPadding() - self.height / 2, 
      nil, round(self.width / 3) - self:hPadding(), self.height - self:vPadding() * 2)
  self.content:add(self.portrait)
  -- Content pos
  local x = round(self.width / 3 - self.width / 2)
  local y = round(self:vPadding() - self.height / 2)
  local w = round((self.width - self:hPadding()) / 3)
  -- Name
  self.textName = SimpleText('', Vector(x, y), w)
  self.content:add(self.textName)
  -- Attributes
  self.attValues = {}
  self:createAtts(self.primary, x, y + 5, w - self:hPadding())
  self:createAtts(self.secondary, x + round(self.width / 3), y + 5, w - self:hPadding())
end
-- Creates the text content from a list of attributes.
-- @param(attList : table) Array of attribute data.
-- @param(x : number) Pixel x of the texts.
-- @param(y : number) Initial pixel y of the texts.
-- @param(w : number) Pixel width of the text box.
function BattlerWindow:createAtts(attList, x, y, w)
  for i = 1, #attList do
    local att = attList[i]
    -- Attribute name
    local posName = Vector(x, y + 10 * i)
    local textName = SimpleText(att.shortName .. ':', posName, w - 30, 'left', font)
    -- Attribute value
    local posValue = Vector(x + 30, y + 10 * i)
    local textValue = SimpleText('', posValue, w, 'left', font)
    -- Store
    self.content:add(textName)
    self.content:add(textValue)
    self.attValues[att.key] = textValue
  end
end

---------------------------------------------------------------------------------------------------
-- Member
---------------------------------------------------------------------------------------------------

-- Shows the given member stats.
-- @param(member : Battler) The battler shown in the window.
function BattlerWindow:setMember(member)
  self:setPortrait(member)
  self.textName:setText(member.name)
  self.textName:redraw()
  -- Attributes
  for key, text in pairs(self.attValues) do
      -- Attribute value
    local total = round(member.att[key]())
    member.att.bonus = false
    local base = round(member.att:getBase(key))
    member.att.bonus = true
    local value = base .. ''
    if base < total then
      value = value .. ' + ' .. (total - base)
    elseif base > total then
      value = value .. ' - ' .. (base - total)
    end
    text:setText(value)
    text:redraw()
  end
  if not self.open then
    self:hideContent()
  end
end
-- Shows the graphics of the given member.
-- If they have a full body image, it is used. Otherwise, it uses the idle animation.
-- @param(member : Battler) The battler shown in the window.
function BattlerWindow:setPortrait(member)
  local char = Database.characters[member.charID]
  if char.portraits.bigIcon then
    local sprite = ResourceManager:loadIcon(char.portraits.bigIcon, GUIManager.renderer)
    sprite:applyTransformation(char.transform)
    self.portrait:setSprite(sprite)
  else
    local anim = char.animations.default.Idle
    local data = Database.animations[anim]
    self.portraitAnim = ResourceManager:loadAnimation(anim, GUIManager.renderer)
    self.portraitAnim:setRow(6)
    self.portraitAnim.sprite:setXYZ(0, 0, 0)
    self.portraitAnim.sprite:applyTransformation(char.transform)
    self.portrait:setSprite(self.portraitAnim.sprite)
  end
  self.portrait:updatePosition(self.position)
end
-- Overrides Window:destroy.
--[[function BattlerWindow:destroy()
  Window.destroy(self)
  if self.portraitAnim then
    self.portraitAnim:destroy()
  end
end]]

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- @ret(string) String representation (for debugging).
function BattlerWindow:__tostring()
  return 'Battler Description Window'
end

return BattlerWindow
