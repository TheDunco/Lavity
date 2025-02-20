extends CharacterBody2D
class_name Player

@export var worldEnvironment: WorldEnvironment

@export_category("Player Config")
@export_range(0, 2) var spriteBasePosition = 0
@export var maxZoom := 0.3
@export var lookThreshold := 50
@export var abilityCutoff := 0.15
@export var moteDrainPercentage := 10
@export var repulseActiveTime := 2.5
@export var decayRate := 0.00015
@export var longevityEffectiveness := 0.00016
@export var damageReductionEffectiveness := 0.001
@export var hungerEffectiveness := 1.75
## How much color gets bled when the player holds to bleed
@export var bleed := 0.25
## Can the player die if they don't have color
@export var invulnerable := false
## Can the player take damage
@export var canTakeDamage := true

@export_category("Player Stats")
@export var baseStatsMult := 1.0
@export var baseMovementSpeed := 12
@export var movementSpeedMult := 20
@export var baseTrackableDistance := 5000.0
@export var cameraBaseZoom := 1.35
@export var deathTimerBaseSeconds := 7
var repulseTime = 0.0

@export var STEALTH_FLASHLIGHT_CUTOFF := 0.7

@onready var reverbBusIndex := AudioServer.get_bus_index("ReverbBus")
@onready var lowPassEffect: AudioEffectLowPassFilter = AudioServer.get_bus_effect(reverbBusIndex, 1)

@onready var moteScene := preload("res://scenes/Objects/Mote.tscn")
@onready var colorRotate = ColorUtils.RGBRotate.new()
@onready var playerLight = $PlayerLight
@onready var playerLightInitScale = playerLight.scale
@onready var defaultSaturation = worldEnvironment.environment.adjustment_saturation

@onready var gravityShape = $GravityArea/GravityShape2D
@onready var gravityShapeInitScale = gravityShape.scale

@onready var flippingSprite = $FlippingSprite
@onready var velocityComponent = $VelocityComponent

@onready var cam: PhantomCamera2D = $"../PlayerFollowingPhantomCam"
@onready var deathTimer = $DeathTimer

@onready var initEnergy = playerLight.energy

# Effects
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var repulseAnimation: AnimationPlayer = $RepulseDistortion/RepulseAnimation

var stats := {
	"damageReduction": 0.5,
	"hunger": 0.5,
	"speed": 0.5,
	"sonar": 0.5,
	"stealth": 0.5,
	"vision": 0.5,
	"longevity": 0.5,
}

var hueRotationSpeed: float
var playerMovementSpeed := movementSpeedMult
var isTrackableByEnemy: bool = true
var trackableDistance := baseTrackableDistance

func _ready() -> void:
	playerLight.color = ColorUtils.PINK
	SignalBus.connect("playerRepulsed", func(_pos): repulseAnimation.play("repulse"))
	$RepulseDistortion.visible = false
	var hrsSetting = Settings.getSetting(Settings.HUE_ROTATION_SPEED)
	if hrsSetting and hrsSetting is float:
		hueRotationSpeed = hrsSetting
	elif hrsSetting:
		hueRotationSpeed = hrsSetting.to_float()
	else:
		hrsSetting = Settings.DEFAULTS.hue_rotation_speed

func handleContinuousInput(delta):
	var isLocked = Input.is_action_pressed("lock")
	var isOnCeiling = is_on_ceiling()
	var isOnFloor = is_on_floor()
	var isOnWall = is_on_wall()

	var isHandlingVelocityInput := false

	if Input.is_action_pressed("right_mouse") and not ColorUtils.isColorDying(playerLight.color):
		var bleedAmount = bleed * delta
		takeDamage(bleedAmount)
		GlobalSfx.playDrain(remap(stats["repulse"], 0.0, 1.0, 0.45, 1.2))
		# TODO: increase the trackable distance when draining
		# TODO: implement sonar when bleeding!
	elif Input.is_action_just_released("right_mouse"):
		GlobalSfx.stopDrain()

	if Input.is_action_pressed("move_right") and not (isLocked and isOnWall):
		isHandlingVelocityInput = true
		velocity.x += playerMovementSpeed
	if Input.is_action_pressed("move_left") and not (isLocked and isOnWall):
		isHandlingVelocityInput = true
		velocity.x -= playerMovementSpeed
	if Input.is_action_pressed("move_up") and not (isLocked and isOnFloor):
		isHandlingVelocityInput = true
		velocity.y -= playerMovementSpeed
	if Input.is_action_pressed("move_down") and not (isLocked and isOnCeiling):
		isHandlingVelocityInput = true
		velocity.y += playerMovementSpeed
		
	if Input.is_action_just_pressed("flip"):
		scale.x = -scale.x
	if Input.is_action_just_pressed("auto_flip"):
		velocityComponent.bypassAutoOrientation = !velocityComponent.bypassAutoOrientation
		
	if Input.is_action_just_pressed("toggle_flashlight"):
		if playerLight.enabled and stats["stealth"] > STEALTH_FLASHLIGHT_CUTOFF:
			playerLight.enabled = false
			particles.process_mode = Node.PROCESS_MODE_DISABLED
			startDying()
		else:
			playerLight.enabled = true
			stopDying()

		isTrackableByEnemy = playerLight.enabled
	
	if isLocked:
		if isOnCeiling or isOnFloor:
			velocity.y = 0
	else:
		# Look towards the direction of travel
		if abs(velocity.x) > lookThreshold or abs(velocity.y) > lookThreshold:
			look_at(velocity.normalized() + position)
			
	if isHandlingVelocityInput:
		flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(self.velocity)
	elif flippingSprite.speed_scale < 0:
		flippingSprite.speed_scale -= 1
	else:
		flippingSprite.speed_scale = 0
		var currentFrame = flippingSprite.frame
		if currentFrame != spriteBasePosition:
			if currentFrame > spriteBasePosition:
				flippingSprite.frame -= 1
			else:
				flippingSprite.frame += 1


func _getStatsFromColor(currentColor: Color) -> Dictionary:
	var statsToSet := {
		"damageReduction": ColorUtils.scoreColorLikeness(currentColor, ColorUtils.RED) * baseStatsMult,
		"hunger": ColorUtils.scoreColorLikeness(currentColor, ColorUtils.ORANGE) * baseStatsMult,
		"speed": ColorUtils.scoreColorLikeness(currentColor, ColorUtils.GREEN) * baseStatsMult,
		"sonar": ColorUtils.scoreColorLikeness(currentColor, ColorUtils.BLUE) * baseStatsMult,
		"stealth": ColorUtils.scoreColorLikeness(currentColor, ColorUtils.BLUE_PURPLE) * baseStatsMult,
		"vision": ColorUtils.scoreColorLikeness(currentColor, ColorUtils.YELLOW) * baseStatsMult,
		"longevity": ColorUtils.scoreColorLikeness(currentColor, ColorUtils.PINK) * baseStatsMult,
		"repulse": ColorUtils.scoreColorLikeness(currentColor, Color.WHITE) * baseStatsMult,
	}
	
	return statsToSet
	
func _setAttributesFromStats():
	# yellow/vision
	var zoomLevel: float = max(cameraBaseZoom - stats["vision"], maxZoom)
	cam.zoom.x = zoomLevel
	cam.zoom.y = zoomLevel
	
	# green/speed
	playerMovementSpeed = (stats["speed"] * movementSpeedMult) + baseMovementSpeed

	# blue purple/stealth
	trackableDistance = (1 - stats["stealth"]) * baseTrackableDistance

	# orange/hunger
	gravityShape.scale = gravityShapeInitScale * (stats["hunger"] * hungerEffectiveness + 0.5)
	playerLight.scale = playerLightInitScale * (stats["hunger"] * hungerEffectiveness + 0.5)

func setChromaticAbberration(on: bool) -> void:
	flippingSprite.use_parent_material = !on
	
func setSaturation(val: float) -> void:
	# TODO: Make this a signal in signal bus that the world env responds to
	worldEnvironment.environment.adjustment_saturation = val

func startDying(shouldPlaySfx: bool = false):
	deathTimer.paused = false
	deathTimer.start(deathTimerBaseSeconds)
	if shouldPlaySfx:
		GlobalSfx.playImminentDeath()
	setSaturation(0.1)

func stopDying():
	deathTimer.stop()
	setSaturation(defaultSaturation)
	GlobalSfx.stopImminentDeath()
	
func takeDamage(damage: float, ambientDamage: bool = false) -> bool:
	if not canTakeDamage:
		return false
	if not ambientDamage:
		var reduction = stats["damageReduction"] * damageReductionEffectiveness
		damage = damage - reduction
		setChromaticAbberration(true)
		$DamageEffectsTimer.start()
	else:
		var reduction = stats["longevity"] * longevityEffectiveness
		damage = damage - reduction
	
	var didTakeDamage = false
	if damage <= 0:
		return didTakeDamage
	
	var newColor = ColorUtils.takeGeneralColorDamage(playerLight.color, damage)
	didTakeDamage = newColor != playerLight.color

	playerLight.color = newColor
	
	return didTakeDamage


func takeColorDamage(color: Color) -> void:
	playerLight.color -= color
	playerLight.color.a = 1.0


func _process(delta):
	# handle death timer and effects
	var playerDying = ColorUtils.isColorDying(playerLight.color) or not playerLight.enabled
	if not playerDying:
		stopDying()
	elif deathTimer.is_stopped():
		startDying(true)

	if playerLight.enabled:
		takeDamage(decayRate, true)
		if ColorUtils.sumVector2(velocity) < 0.3:
			particles.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			particles.process_mode = Node.PROCESS_MODE_INHERIT
	
	particles.color = playerLight.color
	particles.color.a = GlobalConfig.ENTITY_PARTICLES_ALPHA
	
	if deathTimer.is_stopped():
		if lowPassEffect.cutoff_hz <= 20000:
			lowPassEffect.cutoff_hz += 90
	elif lowPassEffect.cutoff_hz > 1000:
			lowPassEffect.cutoff_hz = 1000
		
	stats = _getStatsFromColor(playerLight.color)
	_setAttributesFromStats()

	if repulseTime > 0.0:
		repulseTime -= delta
	if repulseTime > initEnergy:
		playerLight.energy = repulseTime + 0.3
	
	GlobalDynamicMusicComponent.setDynamicTrackVolume(playerLight.color)
	
func _physics_process(delta):
	handleContinuousInput(delta)
	move_and_slide()
	# var collision_info = move_and_collide(velocity * delta)
	# if collision_info:
	# 	var direction = collision_info.get_position().direction_to(global_position)
	# 	velocity += direction * GlobalConfig.LAVITY * 100

	velocity = velocityComponent.handleExistingVelocity(self.velocity)

func _on_damage_effects_timer_timeout() -> void:
	setChromaticAbberration(false)

func _on_death_timer_timeout() -> void:
	if not invulnerable:
		GameFlow.gameOver()

func getLightColor() -> Color:
	return playerLight.color

func rotateColorHue(amount: float) -> void:
	colorRotate.set_hue_rotation(amount)
	var rotatedColor = colorRotate.apply(playerLight.color)
	playerLight.color = rotatedColor

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			rotateColorHue(hueRotationSpeed)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			rotateColorHue(-hueRotationSpeed)
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			# playerLight.color = ColorUtils.getMostSimilarColor(playerLight.color)
			playerLight.color = ColorUtils.YELLOW
			SignalBus.displayHeroText.emit("[center][wave]Cheat[/wave]: Set [rainbow]color[/rainbow] to full[/center]")
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if stats["repulse"] > abilityCutoff and repulseTime <= 0.0:
				takeDamage(bleed * 2)
				GlobalSfx.playRepulse()
				SignalBus.playerRepulsed.emit(global_position)
				repulseTime = 2.5
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var distractingMote = moteScene.instantiate()
			var velocityNormal = velocity.normalized()
			distractingMote.global_position = global_position + (velocityNormal * 100)
			get_tree().root.add_child(distractingMote)
			distractingMote.decayRate = 0.05
			distractingMote.changeColor(playerLight.color)
			distractingMote.applyImpulse(velocityNormal, stats["speed"] * 2000)
			distractingMote.pop.pitch_scale = stats["speed"]
			distractingMote.pop.play()
			takeColorDamage(playerLight.color / moteDrainPercentage)
