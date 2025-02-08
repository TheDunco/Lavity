extends Control
class_name Menu

@export_category("Player Config")
@export var player: Player = null

@export_category("Menu Behavior")
@export var showMainMenuButton := true
@export var visibleByDefault := false

@export var buttonTweenIntensity := 1.05
@export var buttonTweenDuration := 0.08

@export_category("Effect Implementaitons")
@export var _directionalDarkness: DirectonalDarkness
@export var _worldEnvironment: WorldEnvironment

@export_category("Other References")
@export var mainMenuButton: Button = null

@onready var brightnessSlider: HSlider = find_child("BrightnessSlider")
@onready var darknessSlider: HSlider = find_child("DarknessSlider")
@onready var glowIntensitySlider: HSlider = find_child("GlowSlider")
@onready var glowStrengthSlider: HSlider = find_child("GlowStrengthSlider")
@onready var bloomSlider: HSlider = find_child("BloomSlider")
@onready var masterVolumeSlider: HSlider = find_child("MasterVolumeSlider")
@onready var musicVolumeSlider: HSlider = find_child("MusicVolumeSlider")
@onready var sfxVolumeSlider: HSlider = find_child("SfxVolumeSlider")

@onready var masterBusIndex: int = AudioServer.get_bus_index("Master")
@onready var musicBusIndex: int = AudioServer.get_bus_index("Music")
@onready var sfxBusIndex: int = AudioServer.get_bus_index("SFX")

@onready var Buttons = find_children("", "Button", true)
@onready var Sliders = find_children("", "Slider", true)

@onready var version: Label = find_child("Version")
@onready var song: Label = find_child("Song")

@onready var topLevelMenu = $TopLevelMenu
@onready var options = $Options
@onready var controls = $Controls
@onready var play = $Play

@onready var calibrationReference: TextureButton = find_child("CalibrationReference")
func setShowCalibrationReference(shown: bool):
	calibrationReference.visible = shown

func startButtonTween(object: Object, property: String, finalVal: Variant, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(object, property, finalVal, duration)

func buttonMouseEntered(button: Button) -> void:
	button.pivot_offset = button.size / 2
	GlobalSfx.playButtonHover()
	startButtonTween(button, "scale", Vector2(1, 1.2) * buttonTweenIntensity, buttonTweenDuration)

func buttonMouseExited(button: Button) -> void:
	startButtonTween(button, "scale", Vector2.ONE, buttonTweenDuration)

func loadOptions():
	var brightness = Settings.getSetting("BRIGHTNESS")
	if brightness and brightness > 0:
		brightnessSlider.value = brightness

	var darkness = Settings.getSetting("DARKNESS")
	if darkness and darkness > 0:
		darknessSlider.value = darkness
		
	var glow = Settings.getSetting("GLOW")
	if glow and glow > 0:
		glowIntensitySlider.value = glow
		
	var glowStrength = Settings.getSetting("GLOW_STRENGTH")
	if glowStrength and glowStrength > 0:
		glowStrengthSlider.value = glowStrength
		
	var masterVolume = Settings.getSetting("MASTER_VOLUME")
	if masterVolume and masterVolume > masterVolumeSlider.min_value:
		masterVolumeSlider.value = masterVolume
		_on_master_volume_slider_value_changed(masterVolume)

	var musicVolume = Settings.getSetting("MUSIC_VOLUME")
	if musicVolume and musicVolume > musicVolumeSlider.min_value:
		musicVolumeSlider.value = musicVolume
		_on_music_volume_slider_value_changed(musicVolume)

	var sfxVolume = Settings.getSetting("SFX_VOLUME")
	if sfxVolume and sfxVolume > sfxVolumeSlider.min_value:
		sfxVolumeSlider.value = sfxVolume
		_on_sfx_volume_slider_value_changed(sfxVolume)

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
	GameFlow.switchScene("res://scenes/GameModes/Modes/Maze/Maze.tscn")
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
	Settings._saveSettings()

func _on_brightness_slider_value_changed(value):
	Settings.setSetting("BRIGHTNESS", value)
	if _worldEnvironment:
		_worldEnvironment.environment.adjustment_brightness = value
		
func _on_darkness_slider_value_changed(value: float) -> void:
	Settings.setSetting("DARKNESS", value)
	if _directionalDarkness:
		_directionalDarkness.color.a = value
	
func _on_glow_slider_value_changed(value: float) -> void:
	Settings.setSetting("GLOW", value)
	if _worldEnvironment:
		_worldEnvironment.environment.glow_intensity = value
		
func _on_glow_strength_slider_value_changed(value: float) -> void:
	Settings.setSetting("GLOW_STRENGTH", value)
	if _worldEnvironment:
		_worldEnvironment.environment.glow_strength = value
		
func _on_bloom_slider_value_changed(value: float) -> void:
	Settings.setSetting("BLOOM", value)
	if _worldEnvironment:
		_worldEnvironment.environment.glow_bloom = value

func setVolume(value: float, slider: HSlider, busIndex: int, settingName: String):
	Settings.setSetting(settingName, value)
	GlobalSfx.playButtonHover()
	if value == slider.min_value:
		AudioServer.set_bus_mute(busIndex, true)
	else:
		AudioServer.set_bus_mute(busIndex, false)
		AudioServer.set_bus_volume_db(busIndex, value)

func _on_music_volume_slider_value_changed(value: float) -> void:
	setVolume(value, musicVolumeSlider, musicBusIndex, "MUSIC_VOLUME")

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	setVolume(value, sfxVolumeSlider, sfxBusIndex, "SFX_VOLUME")

func _on_master_volume_slider_value_changed(value: float):
	setVolume(value, masterVolumeSlider, masterBusIndex, "MASTER_VOLUME")

func _on_fullscreen_pressed() -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_song_changed(to: String) -> void:
	var labelFormat = "Dunco - %s"
	song.text = labelFormat % to

const DEFAULTS := {
	"brightness": 1.358,
	"darkness": 0.98,
	"glow_intensity": 1.942,
	"glow_strength": 0.868,
	"bloom": 0.04
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

	_on_master_volume_slider_value_changed(0)
	masterVolumeSlider.value = 0
	_on_sfx_volume_slider_value_changed(sfxVolumeSlider.max_value)
	sfxVolumeSlider.value = sfxVolumeSlider.max_value
	_on_music_volume_slider_value_changed(musicVolumeSlider.max_value)
	musicVolumeSlider.value = musicVolumeSlider.max_value

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

func _on_calibration_pressed() -> void:
	GameFlow.switchScene("res://scenes/Worlds/Intro/Calibration.tscn")
	GameFlow.switchToMenuMusic()
