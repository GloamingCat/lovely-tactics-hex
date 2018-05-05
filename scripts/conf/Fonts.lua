
local huge_font = { 'FogSans', 'otf', 20 }
local big_font = { 'FogSans', 'otf', 15 }
local default_font = { 'FogSans', 'otf', 11 }
local medium_font = { 'FogSans', 'otf', 9.5 }
local small_font = { 'FogSans', 'otf', 8 }
local tiny_font = { 'FogSans', 'otf', 6.5 }
local fps_font = { 'FogSans', 'otf', 3 }

return  {
  
  -- Fonts
  gui_title = huge_font,
  gui_default = default_font,
  gui_button = medium_font,
  gui_dialogue = medium_font,
  gui_tiny = tiny_font,
  gui_small = small_font,
  gui_medium = medium_font,
  gui_big = big_font,
  gui_huge = huge_font,
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
