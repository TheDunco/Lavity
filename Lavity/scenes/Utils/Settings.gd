extends Node
class_name Global

const SETTINGS_SAVE_PATH = "user://settings.save"
const _SETTINGS_SECTION = "SETTINGS"

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
