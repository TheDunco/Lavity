extends WorldEnvironment

func _ready() -> void:
	var brightness = GLOBAL.getSetting("BRIGHTNESS")
	if brightness:
		print("setting brightness to ", brightness)
		environment.adjustment_brightness = brightness
	else:
		print("no brightness")
