extends Control
class_name Menu

@export var player: Player = null
@export var snake: CharacterBody2D = null

func loadOptions():
	var brightness = GLOBAL.getSetting("BRIGHTNESS")
	if brightness and brightness > 0:
		$Options/AspectRatioContainer/MarginContainer/VBoxContainer/Brightness/BrightnessSlider.value = brightness
		$"../../WorldEnvironment".environment.adjustment_brightness = brightness
		
	$AspectRatioContainer/MarginContainer/VBoxContainer/Version.text = ProjectSettings.get_setting("application/config/version")

func _ready():
	loadOptions()
	
func _exit_tree() -> void:
	GLOBAL._saveSettings()

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
	GLOBAL._saveSettings()

func _on_brightness_slider_value_changed(value):
	GLOBAL.setSetting("BRIGHTNESS", value)
	$"../../WorldEnvironment".environment.adjustment_brightness = value

func _on_volume_slider_value_changed(value):
	var masterBusIndex = AudioServer.get_bus_index("Master")
	if value == $Options/AspectRatioContainer/MarginContainer/VBoxContainer/Volume/VolumeSlider.min_value:
		AudioServer.set_bus_mute(masterBusIndex, true)
	else:
		AudioServer.set_bus_mute(masterBusIndex, false)
		AudioServer.set_bus_volume_db(masterBusIndex, value)

func _on_procedural_snake_pressed():
	snake.visible = not snake.visible

func _on_light_effects_world_pressed():
	GameFlow.switchScene("res://scenes/Worlds/EffectTestingWorld.tscn")

func _on_fullscreen_pressed() -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
