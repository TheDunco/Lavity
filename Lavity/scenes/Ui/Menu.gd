extends Control
class_name Menu

@export_category("Player Config")
@export var player: Player = null

@export_category("Menu Behavior")
@export var showMainMenuButton := true
@export var visibleByDefault := false

@export var buttonTweenIntensity := 1.07
@export var buttonTweenDuration := 0.01

@export_category("Effect Implementaitons")
@export var _canvasModulateDarkness: CanvasModulate
@export var _worldEnvironment: WorldEnvironment

@export_category("Other References")
@export var mainMenuButton: Button = null

@onready var brightnessSlider: HSlider = find_child("BrightnessSlider")
@onready var darknessSlider: HSlider = find_child("DarknessSlider")
@onready var glowIntensitySlider: HSlider = find_child("GlowSlider")
@onready var glowStrengthSlider: HSlider  = find_child("GlowStrengthSlider")
@onready var bloomSlider: HSlider  = find_child("BloomSlider")
@onready var volumeSlider: HSlider  = find_child("VolumeSlider")

@onready var Buttons = find_children("", "Button", true)
@onready var Sliders = find_children("", "Slider", true)

@onready var version: Label = find_child("Version")
@onready var song: Label = find_child("Song")

@onready var topLevelMenu = $TopLevelMenu
@onready var options = $Options
@onready var controls = $Controls
@onready var play = $Play


func startButtonTween(object: Object, property: String, finalVal: Variant, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(object, property, finalVal, duration)

func buttonMouseEntered(button: Button) -> void:
	button.pivot_offset = button.size / 2
	GlobalSfx.playButtonHover() 
	startButtonTween(button, "scale", Vector2.ONE * buttonTweenIntensity, buttonTweenDuration)

func buttonMouseExited(button: Button) -> void:
	startButtonTween(button, "scale", Vector2.ONE, buttonTweenDuration)

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
	print_debug(volume)
	if volume and volume > volumeSlider.min_value:
		volumeSlider.value = volume
		_on_volume_slider_value_changed(volume)

func _ready():
	loadOptions()
	version.text = ProjectSettings.get_setting("application/config/version")
	MusicComponent.connect("songChanged", _on_song_changed)
	mainMenuButton.visible = showMainMenuButton
	visible = visibleByDefault
	
	for button: Button in Buttons:
		if button:
			button.connect("mouse_entered", func(): buttonMouseEntered(button))
			button.connect("mouse_exited", func(): buttonMouseExited(button))
			button.connect("pressed", GlobalSfx.playButtonClick)

	for slider: Slider in Sliders:
		if slider:
			slider.connect("drag_started", GlobalSfx.playButtonHover)
			slider.connect("drag_ended", GlobalSfx.playButtonHover)
			
	
# Main Menu
func _on_maze_pressed():
	GameFlow.switchScene("res://scenes/GameModes/Modes/Maze.tscn")
	GameFlow.switchToDynamicMusic()
	
func _on_light_effects_world_pressed():
	GameFlow.switchScene("res://scenes/Worlds/EffectTestingWorld.tscn")
	GameFlow.switchToDynamicMusic()

func _on_options_pressed():
	options.show()
	topLevelMenu.hide()
	
func _on_main_menu_button_pressed() -> void:
	GameFlow.switchScene("res://scenes/Ui/Menu2D.tscn")
	GameFlow.switchToMenuMusic()

func _on_quit_pressed():
	GameFlow.quit()

func _on_next_song_pressed():
	MusicComponent.next()
	
# Options
func _on_options_back_pressed():
	options.hide()
	controls.hide()
	play.hide()
	topLevelMenu.show()
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
	GlobalSfx.playButtonHover()
	var masterBusIndex := AudioServer.get_bus_index("Master")
	if value == volumeSlider.min_value:
		AudioServer.set_bus_mute(masterBusIndex, true)
	else:
		AudioServer.set_bus_mute(masterBusIndex, false)
		AudioServer.set_bus_volume_db(masterBusIndex, value)

func _on_fullscreen_pressed() -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_song_changed(to: String) -> void:
	var labelFormat = "Dunco - %s"
	song.text = labelFormat % to

const DEFAULTS := {
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
		GlobalSfx.playTonalClick(0.5)
		visible = not visible

func _on_play_pressed() -> void:
	topLevelMenu.hide()
	play.show()

func _on_controls_pressed() -> void:
	topLevelMenu.hide()
	controls.show()
