
--[[===============================================================================================

ResolutionWindow
---------------------------------------------------------------------------------------------------
Window with resolution options.

=================================================================================================]]

-- Imports
local Button = require('core/gui/widget/Button')
local GridWindow = require('core/gui/GridWindow')

local ResolutionWindow = class(GridWindow)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Implements GridWindow:createWidgets.
function ResolutionWindow:createWidgets()
  Button:fromKey(self, 'resolution2')
  Button:fromKey(self, 'resolution3')
  Button:fromKey(self, 'fullScreen')
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- Chooses new resolution.
function ResolutionWindow:onButtonConfirm(button)
  local scale = button.index + 1
  SaveManager.current.config.resolution = scale
  if scale == 4 then
    ScreenManager:setFullscreen()
  else
    ScreenManager:setScale(scale, scale)
  end
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

-- Overrides GridWindow:colCount.
function ResolutionWindow:colCount()
  return 1
end
-- Overrides GridWindow:rowCount.
function ResolutionWindow:rowCount()
  return 3
end
-- @ret(string) String representation (for debugging).
function ResolutionWindow:__tostring()
  return 'Resolution Window'
end

return ResolutionWindow