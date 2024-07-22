extends CanvasModulate

var newConfig = ConfigFile.new()

func _ready():
	newConfig.load(GLOBAL.SETTINGS_SAVE_PATH)
	var darkness = newConfig.get_value("MAIN", "DARKNESS")
	if darkness:
		print("setting darkness to user setting of ", darkness)
		color.a = darkness
	else:
		print("no darkness")
