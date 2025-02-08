extends Node2D
class_name Calibration

const moteScene = preload("res://scenes/Objects/Mote.tscn")
@onready var menu: Menu = $CanvasLayer/Menu

var calibrationTextIndex := -1
const calibrationText: Array[String] = [
	"\n[center]Welcome, [pulse]Cosmo[/pulse], to the world of [wave]Lavity[/wave]\nWe'll need to adjust your eyes and ears to the environment...[/center]",
	"\n[center]Use [code]Right Arrow[/code] to skip or [code]Left Arrow[/code] to go back through this text[/center]",
	"\n[center]Open the menu with [code]Escape[/code] and navigate to Options with [code]O[/code]",
	"\n[center]Adjust the Brightness slider until the brightest inner ring of your light is just gone",
	"\n[center]Adjust the Darkness slider until the background color matches the reference[/center]",
	"[center]The glow settings are preference, but don't go overboard for the best experience[/center]",
	"[center]Don't forget to match the darkness with the reference if you change the glow[/center]",
	"\n[center]Take this time to adjust the volume to your liking",
	"\n[center]When finished, you may return to the main menu"
]

func instantiateCalibrationMote(color: Color) -> void:
	var calibrationMote = moteScene.instantiate()
	add_child(calibrationMote)
	calibrationMote.decayRate = 0.0
	calibrationMote.changeColor(color)
	calibrationMote.pop.play()

func nextCalibrationText():
	calibrationTextIndex += 1
	if calibrationTextIndex < calibrationText.size() and calibrationTextIndex >= 0:
		SignalBus.displayHeroText.emit(calibrationText[calibrationTextIndex])
	else:
		calibrationTextIndex = calibrationText.size() - 1

func _ready() -> void:
	nextCalibrationText()
	menu.setShowCalibrationReference(true)
	SignalBus.heroTextDoneDisplaying.connect(nextCalibrationText)
	for color in ColorUtils.colorsArray:
		instantiateCalibrationMote(color)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("skip"):
		nextCalibrationText()
	if event.is_action_released("skip_back"):
		calibrationTextIndex -= 2
		nextCalibrationText()
