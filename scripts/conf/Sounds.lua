
local equip = { name = "artisticdude/equip.wav", pitch = 100, volume = 90 }
local coin = { name = "artisticdude/coin.wav", pitch = 100, volume = 90 }
local txt = { name = "GameAudio/text2.wav", pitch = 55, volume = 60 }
local ko = { name = "artisticdude/cloth.wav", pitch = 100, volume = 100 }

return {

	-- GUI
	buttonConfirm = {
		name = "GameAudio/button-confirm.wav",
		pitch = 100,
		volume = 90
	},
	buttonCancel = {
		name = "GameAudio/button-cancel.wav",
		pitch = 100,
		volume = 90
	},
	buttonError = {
		name = "GameAudio/button-error.wav",
		pitch = 120,
		volume = 60
	},
	buttonSelect = {
		name = "GameAudio/button-select.wav",
		pitch = 100,
		volume = 50
	},
	save = {
		name = "GameAudio/save.wav",
		pitch = 100,
		volume = 90
	},
	menu = {
		name = "GameAudio/button-confirm.wav",
		pitch = 100,
		volume = 90
	},
	levelup = {
		name = "GameAudio/levelup.wav",
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
	battleIntro = {
		name = "GameAudio/battle-intro.ogg",
		pitch = 100,
		volume = 100
	},
  
	-- Themes
	titleTheme = {
		name = "David Vitas/Town Theme.ogg",
		pitch = 100,
		volume = 90
	},
	battleTheme = {
		name = "David Vitas/Battle Theme.ogg",
		pitch = 100,
		volume = 90
	},
	victoryTheme = {
		name = "David Vitas/Victory Fanfare.ogg",
		pitch = 100,
		volume = 90
	},
	gameoverTheme = {
		name = "Aaron Krogh/Music Box.ogg",
		pitch = 90,
		volume = 100
	}
  
}