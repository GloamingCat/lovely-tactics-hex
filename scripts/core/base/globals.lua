
--[[===============================================================================================

Globals
---------------------------------------------------------------------------------------------------
This module creates all global variables.

=================================================================================================]]

require('core/base/class')
require('core/base/override')
require('core/math/lib')

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
Sound   = require('conf/Sound')
KeyMap  = require('conf/KeyMap')

---------------------------------------------------------------------------------------------------
-- Util
---------------------------------------------------------------------------------------------------

util = {}
util.array = require('core/base/util/ArrayUtil')
util.table = require('core/base/util/TableUtil')
util.event = require('core/base/util/EventUtil')

---------------------------------------------------------------------------------------------------
-- Plugins
---------------------------------------------------------------------------------------------------

local plugins = require('custom/plugins')
for i = 1, #plugins do
  args = plugins[i]
  if args.on then
    require('custom/plugins/' .. args[1])
  end
end
args = nil

---------------------------------------------------------------------------------------------------
-- Managers
---------------------------------------------------------------------------------------------------

GameManager     = require('core/base/GameManager')()
ResourceManager = require('core/base/ResourceManager')()
InputManager    = require('core/input/InputManager')()
SaveManager     = require('core/save/SaveManager')()
ScreenManager   = require('core/graphics/ScreenManager')()
FieldManager    = require('core/field/FieldManager')()
GUIManager      = require('core/gui/GUIManager')()
BattleManager   = require('core/battle/BattleManager')()
TroopManager    = require('core/battle/TroopManager')()
TurnManager     = require('core/battle/TurnManager')()
