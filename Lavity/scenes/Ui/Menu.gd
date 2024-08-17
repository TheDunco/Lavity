extends Control
class_name Menu

@export var player: Player = null
@export var snake: CharacterBody2D = null

@export var _canvasModulateDarkness: CanvasModulate
@export var _worldEnvironment: WorldEnvironment

func loadOptions():
	var brightness = GLOBAL.getSetting("BRIGHTNESS")
	if brightness and brightness > 0:
		$Options/AspectRatioContainer/MarginContainer/VBoxContainer/Brightness/BrightnessSlider.value = brightness

	var darkness = GLOBAL.getSetting("DARKNESS")
	if darkness and darkness > 0:
		$Options/AspectRatioContainer/MarginContainer/VBoxContainer/Darkness/DarknessSlider.value = darkness
		
	var glow = GLOBAL.getSetting("GLOW")
	if glow and glow > 0:
		$Options/AspectRatioContainer/MarginContainer/VBoxContainer/Glow/GlowSlider.value = glow
		
	var volume = GLOBAL.getSetting("VOLUME")
	if volume and volume > 0:
		$Options/AspectRatioContainer/MarginContainer/VBoxContainer/Volume/VolumeSlider.value = volume
		_on_volume_slider_value_changed(volume)


func _ready():
	loadOptions()
	$AspectRatioContainer/MarginContainer/MarginContainer/VBoxContainer/Version.text = ProjectSettings.get_setting("application/config/version")
	
# Main Menu
func _on_play_pressed():
	GameFlow.switchScene("res://scenes/Worlds/Buildings.tscn")
	MusicComponent.playSong(MusicComponent.SongEnum.A_MOTH_IN_LIGHT)

func _on_options_pressed():
	$Options.show()
	$AspectRatioContainer.hide()

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
	var worldEnv: WorldEnvironment = $"../../WorldEnvironment"
	if _worldEnvironment:
		_worldEnvironment.environment.adjustment_brightness = value
	elif worldEnv:
		worldEnv.environment.adjustment_brightness = value
		
func _on_darkness_slider_value_changed(value: float) -> void:
	GLOBAL.setSetting("DARKNESS", value)
	var canvasModulateDarkness: CanvasModulate = $"../../CanvasModulateDarkness"
	if _canvasModulateDarkness:
		print("alpha", _canvasModulateDarkness.color.a)
		_canvasModulateDarkness.color.a = value
	elif canvasModulateDarkness:
		canvasModulateDarkness.color.a = value
	
	
func _on_glow_slider_value_changed(value: float) -> void:
	GLOBAL.setSetting("GLOW", value)
	var worldEnv: WorldEnvironment = $"../../WorldEnvironment"
	if worldEnv:
		worldEnv.environment.glow_intensity = value

func _on_volume_slider_value_changed(value):
	GLOBAL.setSetting("VOLUME", value)
	var masterBusIndex := AudioServer.get_bus_index("Master")
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
