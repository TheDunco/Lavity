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
	var glowIntensity = GLOBAL.getSetting("GLOW")
	var glowStrength = GLOBAL.getSetting("GLOW_STRENGTH")
	if glowIntensity:
		print("setting glowIntensity to ", glowIntensity)
		environment.glow_enabled = true
		environment.glow_intensity = glowIntensity
	else:
		print("no glow intensity")

	if glowStrength:
		print("setting glowStrength to ", glowStrength)
		environment.glow_enabled = true
		environment.glow_strength = glowStrength
	else:
		print("no glow strength")


func setBloom() -> void:
	var bloom = GLOBAL.getSetting("BLOOM")
	if bloom:
		print("setting bloom to ", bloom)
		environment.glow_bloom = bloom
	else:
		print("no bloom")

func _ready() -> void:
	setBrightness()
	setGlow()
	setBloom()
	
