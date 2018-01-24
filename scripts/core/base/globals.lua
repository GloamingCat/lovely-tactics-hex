
--[[===============================================================================================

Globals
---------------------------------------------------------------------------------------------------
This module creates all global variables.

=================================================================================================]]

require('core/base/class')
require('core/base/override')
require('core/math/lib')

---------------------------------------------------------------------------------------------------
-- Util
---------------------------------------------------------------------------------------------------

util = {}
util.array = require('core/base/util/ArrayUtil')
util.table = require('core/base/util/TableUtil')

---------------------------------------------------------------------------------------------------
-- Database
---------------------------------------------------------------------------------------------------

require('core/base/database')

---------------------------------------------------------------------------------------------------
-- Configuration files
---------------------------------------------------------------------------------------------------

Vocab   = require('conf/Vocab')
Color   = require('conf/Color')
Fonts   = require('conf/Fonts')
Icons   = require('conf/Icons')
KeyMap  = require('conf/KeyMap')

util.event = require('core/base/util/EventUtil')

---------------------------------------------------------------------------------------------------
-- Plugins
---------------------------------------------------------------------------------------------------

for i = 1, #Config.plugins do
  local plugin = Config.plugins[i]
  if plugin.on then
    args = plugin.param
    require('custom/plugins/' .. plugin.path)
  end
end
args = nil

---------------------------------------------------------------------------------------------------
-- Managers
---------------------------------------------------------------------------------------------------

GameManager     = require('core/base/GameManager')()
ResourceManager = require('core/base/ResourceManager')()
AudioManager    = require('core/audio/AudioManager')()
InputManager    = require('core/input/InputManager')()
SaveManager     = require('core/save/SaveManager')()
ScreenManager   = require('core/graphics/ScreenManager')()
FieldManager    = require('core/field/FieldManager')()
GUIManager      = require('core/gui/GUIManager')()
BattleManager   = require('core/battle/BattleManager')()
TroopManager    = require('core/battle/TroopManager')()
TurnManager     = require('core/battle/TurnManager')()
