extends WorldEnvironment

var newConfig = ConfigFile.new()

func _ready() -> void:
	newConfig.load(GLOBAL.SETTINGS_SAVE_PATH)
	var brightness = newConfig.get_value("MAIN", "BRIGHTNESS")
	if brightness:
		environment.adjustment_brightness = brightness
	else:
		print("no brightness")
