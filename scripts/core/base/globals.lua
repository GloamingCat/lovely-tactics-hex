
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
util.table = require('core/base/util/TableUtil')
util.array = require('core/base/util/ArrayUtil')

---------------------------------------------------------------------------------------------------
-- Database
---------------------------------------------------------------------------------------------------

Database = require('core/base/Database')

---------------------------------------------------------------------------------------------------
-- Configuration files
---------------------------------------------------------------------------------------------------

Vocab   = require('conf/Vocab')
Color   = require('conf/Color')
Fonts   = require('conf/Fonts')
Icons   = require('conf/Icons')
Sounds  = require('conf/Sounds')
KeyMap  = require('conf/KeyMap')

---------------------------------------------------------------------------------------------------
-- Plugins
---------------------------------------------------------------------------------------------------

local TagMap = require('core/base/datastruct/TagMap')
for i = 1, #Config.plugins do
  local plugin = Config.plugins[i]
  if plugin.on then
    args = TagMap(plugin.tags)
    require('custom/' .. plugin.name)
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
SaveManager     = require('core/base/save/SaveManager')()
ScreenManager   = require('core/graphics/ScreenManager')()
FieldManager    = require('core/field/FieldManager')()
GUIManager      = require('core/gui/GUIManager')()
BattleManager   = require('core/battle/BattleManager')()
TroopManager    = require('core/battle/TroopManager')()
TurnManager     = require('core/battle/TurnManager')()
