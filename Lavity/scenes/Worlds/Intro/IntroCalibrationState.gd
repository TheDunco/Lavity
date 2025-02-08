extends IntroState
class_name IntroCalibrationState

const moteScene = preload("res://scenes/Objects/Mote.tscn")
@onready var heroTextTweenTimer = Timer.new()


var currentHeroTextIndex := -1
const heroText: Array[String] = [
	"\n\n[center]Welcome, [pulse]Cosmo[/pulse], to the world of [wave]Lavity[/wave][/center]",
	"\n\n[center]We'll need to adjust your eyes and ears to the environment...[/center]",
	"\n[center]Use [code]Right Arrow[/code] to skip or [code]Left Arrow[/code] to go back through this text[/center]",
	"\n[center]Open the menu with [code]Escape[/code] and navigate to Options with [code]O[/code]",
	"\n[center]Adjust the Brightness slider until the brightest inner ring of your light is just gone",
	"\n[center]Adjust the Darkness slider until the background color matches the reference[/center]",
	"[center]The glow settings are preference, but don't go overboard for the best experience[/center]",
	"[center]Don't forget to match the darkness with the reference if you change the glow[/center]",
	"\n[center]Take this time to adjust the volume to your liking",
	"\n[center]When finished, press [code]B[/code] then [code]C[/code] to go back and view the controls",
	"\n[center]You can move around with [code]W A S D[/code] to collect color. You'll need it to survive![/center]",
	"\n[center]You can spend color to spawn a mote with [code]Left Mouse[/code] or repulse enemies and motes with [code]Right Mouse[/code][/center]",
	"\n[center]Different colors give you different effects[/center]"
]

func instantiateCalibrationMote(color: Color) -> void:
	var calibrationMote = moteScene.instantiate()
	add_child(calibrationMote)
	calibrationMote.decayRate = 0.0
	calibrationMote.changeColor(color)
	# calibrationMote.pop.pitch_scale = lerp(ColorUtils.sumVector2(position), 
	calibrationMote.pop.play()

func nextHeroText():
	currentHeroTextIndex += 1
	if currentHeroTextIndex < heroText.size() and currentHeroTextIndex >= 0:
		SignalBus.displayHeroText.emit(heroText[currentHeroTextIndex])
	else:
		currentHeroTextIndex = heroText.size() - 1

func enter():
	add_child(heroTextTweenTimer)
	heroTextTweenTimer.wait_time = GlobalConfig.HERO_TEXT_TWEEN_TIME
	heroTextTweenTimer.connect("timeout", nextHeroText)
	heroTextTweenTimer.start()
	nextHeroText()
	for color in ColorUtils.colorsArray:
		instantiateCalibrationMote(color)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("skip"):
		nextHeroText()
	if event.is_action_released("skip_back"):
		currentHeroTextIndex -= 2
		nextHeroText()
