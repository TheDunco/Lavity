extends WorldEnvironment

func setBrightness() -> void:
	var brightness = GLOBAL.getSetting("BRIGHTNESS")
	if brightness:
		print("setting brightness to ", brightness)
		environment.adjustment_enabled = true
		environment.adjustment_brightness = brightness
	else:
		print("no brightness")
		
func setGlow() -> void:
	var glow = GLOBAL.getSetting("GLOW")
	if glow:
		print("setting glow to ", glow)
		environment.glow_enabled = true
		environment.glow_intensity = glow
	else:
		print("no brightness")

func _ready() -> void:
	setBrightness()
	setGlow()
	
