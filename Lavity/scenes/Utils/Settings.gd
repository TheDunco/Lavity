extends Node
class_name GlobalSettings

const SETTINGS_SAVE_PATH = "user://settings.save"
const _SETTINGS_SECTION = "SETTINGS"

const BRIGHTNESS = "BRIGHTNESS"
const DARKNESS = "DARKNESS"
const GLOW = "GLOW"
const GLOW_STRENGTH = "GLOW_STRENGTH"
const BLOOM = "BLOOM"
const MASTER_VOLUME = "MASTER_VOLUME"
const MUSIC_VOLUME = "MUSIC_VOLUME"
const SFX_VOLUME = "SFX_VOLUME"
const HUE_ROTATION_SPEED = "HUE_ROTATION_SPEED"

const DEFAULTS := {
	"brightness": 1.358,
	"darkness": 0.98,
	"glow_intensity": 1.942,
	"glow_strength": 0.868,
	"bloom": 0.04,
	"hue_rotation_speed": 2.0
}

var settingsConfig = ConfigFile.new()
var _loadOk = settingsConfig.load(SETTINGS_SAVE_PATH)

func getSetting(key: String):
	# print(settingsConfig.encode_to_text())
	var val = settingsConfig.get_value(_SETTINGS_SECTION, key)
	if not val:
		print("failed to get setting ", key)
	
	return val

func setSetting(key: String, value):
	settingsConfig.set_value(_SETTINGS_SECTION, key, value)
	_saveSettings()
		
func _saveSettings():
	settingsConfig.save(SETTINGS_SAVE_PATH)
	
func _exit_tree() -> void:
	_saveSettings()
