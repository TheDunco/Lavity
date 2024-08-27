extends Control
class_name Menu

@export_category("Player Config")
@export var player: Player = null
@export var snake: CharacterBody2D = null

@export_category("Menu Behavior")
@export var showMainMenuButton := true
@export var visibleByDefault := false

@export_category("Effect Implementaitons")
@export var _canvasModulateDarkness: CanvasModulate
@export var _worldEnvironment: WorldEnvironment

@export_category("Sliders")
@export var brightnessSlider: HSlider = null
@export var darknessSlider: HSlider = null
@export var glowIntensitySlider: HSlider = null
@export var glowStrengthSlider: HSlider = null
@export var bloomSlider: HSlider = null
@export var volumeSlider: HSlider = null

@export_category("Other References")
@export var mainMenuButton: Button = null

func loadOptions():
	var brightness = GLOBAL.getSetting("BRIGHTNESS")
	if brightness and brightness > 0:
		brightnessSlider.value = brightness

	var darkness = GLOBAL.getSetting("DARKNESS")
	if darkness and darkness > 0:
		darknessSlider.value = darkness
		
	var glow = GLOBAL.getSetting("GLOW")
	if glow and glow > 0:
		glowIntensitySlider.value = glow
		
	var glowStrength = GLOBAL.getSetting("GLOW_STRENGTH")
	if glowStrength and glowStrength > 0:
		glowStrengthSlider.value = glowStrength
		
	var volume = GLOBAL.getSetting("VOLUME")
	if volume and volume > 0:
		volumeSlider.value = volume
		_on_volume_slider_value_changed(volume)


func _ready():
	loadOptions()
	$AspectRatioContainer/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/Version.text = ProjectSettings.get_setting("application/config/version")
	MusicComponent.connect("songChanged", _on_song_changed)
	mainMenuButton.visible = showMainMenuButton
	visible = visibleByDefault

# Main Menu
func _on_play_pressed():
	GameFlow.switchScene("res://scenes/Worlds/Tutorial.tscn")
	MusicComponent.playSong(MusicComponent.SongEnum.ECHOES_FROM_THE_DARK)
	
func _on_light_effects_world_pressed():
	GameFlow.switchScene("res://scenes/Worlds/EffectTestingWorld.tscn")

func _on_options_pressed():
	$Options.show()
	$AspectRatioContainer.hide()
	
func _on_main_menu_button_pressed() -> void:
	GameFlow.switchScene("res://scenes/Ui/Menu2D.tscn")

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
	if _worldEnvironment:
		_worldEnvironment.environment.adjustment_brightness = value
		
func _on_darkness_slider_value_changed(value: float) -> void:
	GLOBAL.setSetting("DARKNESS", value)
	if _canvasModulateDarkness:
		_canvasModulateDarkness.color.a = value
	
func _on_glow_slider_value_changed(value: float) -> void:
	GLOBAL.setSetting("GLOW", value)
	if _worldEnvironment:
		_worldEnvironment.environment.glow_intensity = value
		
func _on_glow_strength_slider_value_changed(value: float) -> void:
	GLOBAL.setSetting("GLOW_STRENGTH", value)
	if _worldEnvironment:
		_worldEnvironment.environment.glow_strength = value
		
func _on_bloom_slider_value_changed(value: float) -> void:
	GLOBAL.setSetting("BLOOM", value)
	if _worldEnvironment:
		_worldEnvironment.environment.glow_bloom = value

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

func _on_fullscreen_pressed() -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_song_changed(to: String) -> void:
	var labelFormat = "Dunco - %s"
	$AspectRatioContainer/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/Song.text = labelFormat % to

var DEFAULTS := {
	"brightness": 1.24,
	"darkness": 0.941,
	"glow_intensity": 2.77,
	"glow_strength": 1.4,
	"bloom": 0.02
}

func _on_reset_to_default_pressed() -> void:
	_on_brightness_slider_value_changed(DEFAULTS.brightness)
	brightnessSlider.value = DEFAULTS.brightness
	
	_on_darkness_slider_value_changed(DEFAULTS.darkness)
	darknessSlider.value = DEFAULTS.darkness
	
	_on_glow_slider_value_changed(DEFAULTS.glow_intensity)
	glowIntensitySlider.value = DEFAULTS.glow_intensity
	
	_on_glow_strength_slider_value_changed(DEFAULTS.glow_strength)
	glowStrengthSlider.value = DEFAULTS.glow_strength
	
	_on_bloom_slider_value_changed(DEFAULTS.bloom)
	bloomSlider.value = DEFAULTS.bloom

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_esc"):
		visible = not visible
