extends Control
class_name Menu

var newConfig = ConfigFile.new()
var configFile = newConfig.load(GLOBAL.SETTINGS_SAVE_PATH)

func _ready():
	var darkness = newConfig.get_value("MAIN", "DARKNESS")
	if darkness and darkness > 0:
		$Options/AspectRatioContainer/MarginContainer/VBoxContainer/Darkness/DarknessSlider.value = darkness

# Main Menu
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/Worlds/TestWorld.tscn")

func _on_options_pressed():
	$Options.show()
	$AspectRatioContainer.hide()

func _on_quit_pressed():
	get_tree().quit()
	
# Options
func _on_options_back_pressed():
	$Options.hide()
	$AspectRatioContainer.show()
	newConfig.save(GLOBAL.SETTINGS_SAVE_PATH)

func _on_brightness_slider_value_changed(value):
	newConfig.set_value("MAIN", "DARKNESS", value)
	$"../../CanvasModulateDarkness".color.a = value
