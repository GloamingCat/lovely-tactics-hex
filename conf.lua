
--[[===============================================================================================

Conf
---------------------------------------------------------------------------------------------------
File run before main. Prepares window.

=================================================================================================]]

love.filesystem.setRequirePath('scripts/?.lua;/?.lua')
local Serializer = require('core/base/save/Serializer')

function love.conf(t)
  Config = Serializer.load('data/system/config.json')
  t.identity = Config.name 
  t.window.title = Config.name
  t.window.icon = 'images/icon24.png'
  t.window.width = Config.screen.nativeWidth * Config.screen.widthScale
  t.window.height = Config.screen.nativeHeight * Config.screen.heightScale
  t.window.fullscreentype = 'desktop'
  t.window.vsync = true
  t.modules.joystick = false
  t.modules.physics = false
end
