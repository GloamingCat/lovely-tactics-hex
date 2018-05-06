
--[[===============================================================================================

KeyMap
---------------------------------------------------------------------------------------------------
The [code -> type] map. Each code represents the key pressed, and the type is the string that is 
going to be used by the game logic.

=================================================================================================]]

return {
  z           = 'confirm',
  ['return']  = 'confirm',
  x           = 'cancel',
  backspace   = 'cancel',
  p           = 'pause',
  pause       = 'pause',
  rshift      = 'dash',
  lshift      = 'dash',
  mouse1      = 'mouse1',
  mouse2      = 'mouse2',
  mouse3      = 'mouse3',
  pagedown    = 'prev',
  n           = 'prev',
  pageup      = 'next',
  m           = 'next'
}
