
--[[===============================================================================================

KeyMap
---------------------------------------------------------------------------------------------------
The [code -> type] map. Each code represents the key pressed, and the type is the string that is 
going to be used by the game logic.

=================================================================================================]]

return {
  ['return']  = 'confirm',
  space       = 'confirm',
  kpenter     = 'confirm',
  z           = 'confirm',
  x           = 'cancel',
  backspace   = 'cancel',
  escape      = 'cancel',
  p           = 'pause',
  pause       = 'pause',
  rshift      = 'dash',
  lshift      = 'dash',
  up          = 'up',
  left        = 'left',
  right       = 'right',
  down        = 'down',
  w           = 'up',
  a           = 'left',
  d           = 'right',
  s           = 'down',
  pagedown    = 'prev',
  n           = 'prev',
  pageup      = 'next',
  m           = 'next'
}
