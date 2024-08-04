extends Control
class_name Menu

var newConfig = ConfigFile.new()
var configFile = newConfig.load(GLOBAL.SETTINGS_SAVE_PATH)
@export var player: Player = null
@export var snake: CharacterBody2D = null

func loadOptions():
	var brightness = newConfig.get_value("MAIN", "BRIGHTNESS")
	if brightness and brightness > 0:
		$Options/AspectRatioContainer/MarginContainer/VBoxContainer/Brightness/BrightnessSlider.value = brightness
		
	$AspectRatioContainer/MarginContainer/VBoxContainer/Version.text = ProjectSettings.get_setting("application/config/version")

func _ready():
	loadOptions()

# Main Menu
func _on_play_pressed():
	GameFlow.switchScene("res://scenes/Worlds/TestWorld.tscn")
	MusicComponent.playSong(MusicComponent.SongEnum.A_MOTH_IN_LIGHT)

func _on_options_pressed():
	$Options.show()
	$AspectRatioContainer.hide()
	
func _on_summon_player_pressed():
	player.position = $AspectRatioContainer/MarginContainer/VBoxContainer/SummonPlayer.global_position
	player.velocity = Vector2.ZERO

func _on_quit_pressed():
	GameFlow.quit()

func _on_next_song_pressed():
	MusicComponent.next()
	
# Options
func _on_options_back_pressed():
	$Options.hide()
	$AspectRatioContainer.show()
	newConfig.save(GLOBAL.SETTINGS_SAVE_PATH)

func _on_brightness_slider_value_changed(value):
	newConfig.set_value("MAIN", "BRIGTHNESS", value)
	$"../../WorldEnvironment".environment.adjustment_brightness = value

func _on_volume_slider_value_changed(value):
	if value == $Options/AspectRatioContainer/MarginContainer/VBoxContainer/Volume/VolumeSlider.min_value:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _on_procedural_snake_pressed():
	snake.visible = not snake.visible

func _on_light_effects_world_pressed():
	GameFlow.switchScene("res://scenes/Worlds/EffectTestingWorld.tscn")

func _on_fullscreen_pressed() -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
