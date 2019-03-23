
local equip = { name = "sfx/artisticdude/equip.wav", pitch = 100, volume = 90 }
local coin = { name = "sfx/artisticdude/coin.wav", pitch = 100, volume = 90 }
local txt = { name = "sfx/GameAudio/text2.wav", pitch = 55, volume = 60 }
local ko = { name = "sfx/artisticdude/cloth.wav", pitch = 100, volume = 100 }

return {

	-- GUI
	buttonConfirm = {
		name = "sfx/GameAudio/button-confirm.wav",
		pitch = 100,
		volume = 90
	},
	buttonCancel = {
		name = "sfx/GameAudio/button-cancel.wav",
		pitch = 100,
		volume = 90
	},
	buttonError = {
		name = "sfx/GameAudio/button-error.wav",
		pitch = 120,
		volume = 60
	},
	buttonSelect = {
		name = "sfx/GameAudio/button-select.wav",
		pitch = 100,
		volume = 50
	},
	save = {
		name = "sfx/GameAudio/save.wav",
		pitch = 100,
		volume = 90
	},
	menu = {
		name = "sfx/GameAudio/button-confirm.wav",
		pitch = 100,
		volume = 90
	},
	levelup = {
		name = "sfx/GameAudio/levelup.wav",
		pitch = 120,
		volume = 100
	},
	text = txt,
	exp = txt,
	equip = equip,
	unequip = equip,
	buy = coin,
	sell = coin,

	-- Battle
	allyKO = ko,
	enemyKO = ko,
  escape = {
		name = "sfx/Kenney/footstep01x4.ogg",
		pitch = 100,
		volume = 100
  },
	battleIntro = {
		name = "sfx/GameAudio/battle-intro.ogg",
		pitch = 100,
		volume = 100
	},
  
	-- Themes
	titleTheme = {
		name = "bgm/David Vitas/Town Theme.ogg",
		pitch = 100,
		volume = 90
	},
	battleTheme = {
		name = "bgm/David Vitas/Battle Theme.ogg",
		pitch = 100,
		volume = 90
	},
	victoryTheme = {
		name = "bgm/David Vitas/Victory Fanfare.ogg",
		pitch = 100,
		volume = 90
	},
	gameoverTheme = {
		name = "bgm/Aaron Krogh/Music Box.ogg",
		pitch = 90,
		volume = 100
	}
  
}