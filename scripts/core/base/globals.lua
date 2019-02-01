
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
-- Event
---------------------------------------------------------------------------------------------------

util.event = require('core/base/event/GeneralEvents')
local events = {'GUI', 'Character', 'Screen', 'Sound'}
for i = 1, #events do
  local Events = require('core/base/event/' .. events[i] .. 'Events')
  for k, v in pairs(Events) do
    util.event[k] = v
  end
end

---------------------------------------------------------------------------------------------------
-- Plugins
---------------------------------------------------------------------------------------------------

for i = 1, #Config.plugins do
  local plugin = Config.plugins[i]
  if plugin.on then
    args = plugin.tags
    require('custom/plugins/' .. plugin.name)
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
