
--[[===============================================================================================

Globals
---------------------------------------------------------------------------------------------------
This module creates all global variables.

=================================================================================================]]

require('core/base/class')
require('core/math/lib')
require('core/base/override')

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

Color   = require('conf/Color')
Fonts   = require('conf/Fonts')
Icons   = require('conf/Icons')
Sounds  = require('conf/Sounds')
KeyMap  = require('conf/KeyMap')
Vocab   = require('vocab/English')

---------------------------------------------------------------------------------------------------
-- Field Math
---------------------------------------------------------------------------------------------------

local tileW = Config.grid.tileW
local tileH = Config.grid.tileH
local tileB = Config.grid.tileB
local tileS = Config.grid.tileS
if (tileW == tileB) and (tileH == tileS) then
  math.field = require('core/math/field/OrtMath')
elseif (tileB == 0) and (tileS == 0) then
  math.field = require('core/math/field/IsoMath')
elseif (tileB > 0) and (tileS == 0) then
  math.field = require('core/math/field/HexVMath')
elseif (tileB == 0) and (tileS > 0) then
  math.field = require('core/math/field/HexHMath')
else
  error('Tile format not supported!')
end
math.field.init()

---------------------------------------------------------------------------------------------------
-- Plugins
---------------------------------------------------------------------------------------------------

local TagMap = require('core/datastruct/TagMap')
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
SaveManager     = require('core/save/SaveManager')()
ScreenManager   = require('core/graphics/ScreenManager')()
FieldManager    = require('core/field/FieldManager')()
GUIManager      = require('core/gui/GUIManager')()
BattleManager   = require('core/battle/BattleManager')()
TroopManager    = require('core/battle/TroopManager')()
TurnManager     = require('core/battle/TurnManager')()
