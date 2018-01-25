
--[[===============================================================================================

IconList
---------------------------------------------------------------------------------------------------


=================================================================================================]]

local IconList = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function IconList:init(topLeft, width, height)
  self.list = {}
  self.topLeft = topLeft
  self.width = width
  self.height = height
  self.visible = true
end

function IconList:setIcons(icons)
  self:destroy()
  self.list = {}
  if not icons then
    return
  end
  local x, y = 0, 0
  for i = 1, #icons do
    local anim = ResourceManager:loadIconAnimation(icons[i], GUIManager.renderer)
    local _, _, w, h = anim.sprite:totalBounds()
    if x + w > self.width then
      if y + h > self.height then
        anim:destroy()
        break
      end
      if x > 0 then
        x = 0
        y = y + h
      end
    end
    self.list[i] = anim
    anim.x = x
    anim.y = y
    anim.sprite:setVisible(self.visible)
    x = x + w
  end
end

---------------------------------------------------------------------------------------------------
-- Widget
---------------------------------------------------------------------------------------------------

function IconList:show()
  for i = 1, #self.list do
    self.list[i]:show()
  end
  self.visible = true
end

function IconList:hide()
  for i = 1, #self.list do
    self.list[i]:hide()
  end
  self.visible = false
end

function IconList:update()
  for i = 1, #self.list do
    self.list[i]:update()
  end
end

function IconList:destroy()
  for i = 1, #self.list do
    self.list[i]:destroy()
  end
end

function IconList:updatePosition(wpos)
  for i = 1, #self.list do
    local x = wpos.x + self.topLeft.x + self.list[i].x
    local y = wpos.y + self.topLeft.y + self.list[i].y
    self.list[i].sprite:setXYZ(x, y)
  end
end

return IconList