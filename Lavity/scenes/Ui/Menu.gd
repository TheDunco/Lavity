extends Control
class_name Menu

var newConfig = ConfigFile.new()
var configFile = newConfig.load(GLOBAL.SETTINGS_SAVE_PATH)
@export var player: Player = null

func loadOptions():
	var darkness = newConfig.get_value("MAIN", "DARKNESS")
	if darkness and darkness > 0:
		$Options/AspectRatioContainer/MarginContainer/VBoxContainer/Darkness/DarknessSlider.value = darkness
		
	$AspectRatioContainer/MarginContainer/VBoxContainer/Version.text = GLOBAL.VERSION

func _on_light_finished():
	$Gravity.play()
	
func _on_gravity_finished():
	$Light.play()

func _ready():
	loadOptions()
	$Light.play()

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

func _on_summon_player_pressed():
	print("mouse: ", get_global_mouse_position(), "player: ", player.global_position)
	player.position = $AspectRatioContainer/MarginContainer/VBoxContainer/SummonPlayer.global_position
	player.velocity = Vector2.ZERO
	
func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
