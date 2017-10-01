
local default_font = { 'FogSans', 'otf', 44 }
local medium_font = { 'FogSans', 'otf', 38 }
local small_font = { 'FogSans', 'otf', 32 }
local fps_font = { 'FogSans', 'otf', 12 }

return  {
  
  -- Fonts
  gui_default = default_font,
  gui_button = default_font,
  gui_dialogue = default_font,
  gui_small = small_font,
  gui_medium = medium_font,
  popup_dmghp = default_font,
  popup_dmgsp = default_font,
  popup_healhp = default_font,
  popup_healsp = default_font,
  popup_miss = default_font,
  popup_status_add = default_font,
  popup_status_remove = default_font,
  fps = fps_font,
  
  -- Settings
  scale = 4,
  outlineSize = 4
  
}
