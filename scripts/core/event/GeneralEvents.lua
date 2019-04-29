
--[[===============================================================================================

Event Utilities
---------------------------------------------------------------------------------------------------
Functions that are loaded from the EventSheet.

=================================================================================================]]

-- Imports
local AIRule = require('core/battle/ai/AIRule')
local TagMap = require('core/datastruct/TagMap')

local Event = {}

---------------------------------------------------------------------------------------------------
-- Field
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(args.fade : boolean) Fade time (optional, no fading by default);
-- @param(args.fieldID : number) Field to loaded's ID;

-- Teleports player to other field.
-- @param(args.x : number) Player's destination x.
-- @param(args.y : number) Player's destination y.
-- @param(args.h : number) Player's destination height.
-- @param(args.direction : number) Player's destination direction (in degrees).
function Event:moveToField(args)
  local fade = args.fade and {time = args.fade, wait = true}
  if fade then
    if self.tile then
      self.root:fork(function()
        -- Character
        if self.player.autoTurn then
          self.player:turnToTile(self.tile.x, self.tile.y)
        end
        self.player:walkToTile(self.tile:coordinates())
      end)
    end
    self:fadeout(fade)
  end
  FieldManager:loadTransition(args)
  if fade then
    FieldManager.renderer:fadeout(0)
    self:fadein(fade)
  end
end
-- Loads battle field.
-- @param(args.intro : boolean) Battle introduction animation.
-- @param(args.gameOverCondition : number) GameOver condition:
--  0 => no gameover, 1 => only when lost, 2 => lost or draw.
-- @param(args.escapeEnabled : boolean) True to enable the whole party to escape.
function Event:startBattle(args)
  local fiber = FieldManager.fiberList:fork(function()
    local bgm = AudioManager:pauseBGM()
    ::retry::
    if Sounds.battleIntro then
      AudioManager:playSFX(Sounds.battleIntro)
    end
    local shaderArgs = {name = 'BattleIntro'}
    if args.fade then
      local shader = ScreenManager.shader
      self:shaderin(shaderArgs)
      if AudioManager.battleTheme then
        AudioManager:playBGM(AudioManager.battleTheme)
      end
      ScreenManager.shader = shader
    end
    local result = FieldManager:loadBattle(args.fieldID, args)
    if result == 2 then -- Retry
      goto retry
    elseif result == 3 then -- Title Screen
      GameManager:restart()
    elseif bgm then
      AudioManager:playBGM(bgm)
      if args.fade then
        FieldManager.renderer:fadeout(0)
        FieldManager.renderer:fadein(args.fade, true)
      end
    end
  end)
  fiber:waitForEnd()
end

return Event