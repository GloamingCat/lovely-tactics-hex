
--[[===============================================================================================

Sound Utilities
---------------------------------------------------------------------------------------------------
Functions that are loaded from the EventSheet.

=================================================================================================]]

local util = {}

---------------------------------------------------------------------------------------------------
-- Sound
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(args.name : string) The path to the sound from audio/bgm (BGMs) or audio/sfx (SFX).
-- @param(args.volume : number) Volume in percentage.
-- @param(args.pitch : number) Pitch in percentage.
-- @param(args.time : number) The duration of the BGM fading transition.
-- @param(args.wait : boolean) Wait for the BGM fading transition or until SFX finishes.

-- Changes the current BGM.
function util.playBGM(sheet, args)
  AudioManager:playBGM(args, args.time, args.wait)
end
-- Pauses current BGM.
function util.pauseBGM(sheet, args)
  AudioManager:pauseBGM(args, args.time, args.wait)
end
-- Resumes current BGM.
function util.resumeBGM(sheet, args)
  AudioManager:resumeBGM(args, args.time, args.wait)
end
-- Play a sound effect.
function util.playSFX(sheet, args)
  AudioManager:playSFX(args)
end

return util