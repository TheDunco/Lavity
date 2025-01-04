extends CharacterBody2D
class_name Player

@export var worldEnvironment: WorldEnvironment
@onready var defaultSaturation = worldEnvironment.environment.adjustment_saturation

@export_category("Player Config")
@export_range(0, 2) var spriteBasePosition = 0
@export var maxZoom := 0.3
@export var lookThreshold := 50
@export var cameraBaseZoom := 1.35
@export var deathTimerBaseSeconds := 7
@export var hueRotationSpeed := 2.0

var colorRotate = GLOBAL_UTILS.RGBRotate.new()

@export_category("Player Stats")
@export var baseStatsMult := 1.0
@export var baseMovementSpeed := 7
@export var movementSpeedMult := 20
@export var baseTrackableDistance := 2500.0

@export var STEALTH_FLASHLIGHT_CUTOFF := 0.82
@export var SUM_DAMAGE_CUTOFF := 0.03

@onready var reverbBusIndex := AudioServer.get_bus_index("ReverbBus")
@onready var lowPassEffect: AudioEffectLowPassFilter = AudioServer.get_bus_effect(reverbBusIndex, 1)

var stats := {
	"damageReduction": 0.5,
	"damage" : 0.5,
	"speed": 0.5,
	"sonar": 0.5,
	"stealth": 0.5,
	"vision": 0.5,
	"regeneration": 0.5,
}

var playerMovementSpeed := movementSpeedMult
var isTrackableByEnemy: bool = true
var trackableDistance := baseTrackableDistance

func _ready() -> void:
	$PlayerLight.color = Color.RED

func handleInput():
	var isLocked = Input.is_action_pressed("lock")
	var isOnCeiling = is_on_ceiling()
	var isOnFloor = is_on_floor()
	var isOnWall = is_on_wall()

	var isHandlingVelocityInput := false

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
		$VelocityComponent.bypassAutoOrientation = !$VelocityComponent.bypassAutoOrientation
		
	if Input.is_action_just_pressed("toggle_flashlight") :
		if $PlayerLight.enabled and stats["stealth"] > STEALTH_FLASHLIGHT_CUTOFF:
			$PlayerLight.enabled = false
			startDying()
		else:
			$PlayerLight.enabled = true
			stopDying()

		isTrackableByEnemy = $PlayerLight.enabled
	
	if isLocked:
		#$VelocityComponent.bypassAutoOrientation = true
		if isOnCeiling or isOnFloor:
			velocity.y = 0
	else:
		#$VelocityComponent.bypassAutoOrientation = false
		# Look towards the direction of travel
		if abs(velocity.x) > lookThreshold or abs(velocity.y) > lookThreshold:
			look_at(velocity.normalized() + position)
			
	if isHandlingVelocityInput:
		$FlippingSprite.speed_scale = $VelocityComponent.getAnimationSpeed(self.velocity)
	elif $FlippingSprite.speed_scale < 0:
		$FlippingSprite.speed_scale -= 1
	else:
		$FlippingSprite.speed_scale = 0
		var currentFrame = $FlippingSprite.frame
		if currentFrame != spriteBasePosition:
			if currentFrame > spriteBasePosition:
				$FlippingSprite.frame -= 1
			else:
				$FlippingSprite.frame += 1

var time := 0.0
func getPulseTime(delta):
	time += max($FlippingSprite.speed_scale, 3) * delta
	if time > 1.0e30:
		time = 0.0
	return sin(time)
	
func getLightColor() -> Color:
	return $PlayerLight.color

func _getStatsFromColor(currentColor: Color) -> Dictionary:
	var statsPerColor := {}
	
	# Figure out how similar to each color we are
	for colorName in GLOBAL_UTILS.colorNames:
		statsPerColor[colorName] = GLOBAL_UTILS.scoreColorLikeness(currentColor, GLOBAL_UTILS.colors[colorName])
	
	var white = GLOBAL_UTILS.scoreColorLikeness(currentColor, Color.WHITE)
	var black = GLOBAL_UTILS.scoreColorLikeness(currentColor, Color.BLACK)/2

	# Map that to the stats
	var statsToSet := {
		"damageReduction": (statsPerColor["red"] + white - black) * baseStatsMult,
		"damage" : (statsPerColor["orange"] + white - black) * baseStatsMult,
		"speed": (statsPerColor["green"] + white - black) * baseStatsMult,
		"sonar": (statsPerColor["blue"] + white - black) * baseStatsMult,
		"stealth": (statsPerColor["blue_purple"]) * baseStatsMult,
		"vision": (statsPerColor["yellow"] + white/4 - black) * baseStatsMult,
		"regeneration": (statsPerColor["pink"] + white - black) * baseStatsMult,
	}
	
	return statsToSet
	
func _setAttributesFromStats():
	# yellow/vision
	var zoomLevel: float = max(cameraBaseZoom - stats["vision"], maxZoom)
	$"../PlayerFollowingPhantomCam".zoom.x = zoomLevel
	$"../PlayerFollowingPhantomCam".zoom.y = zoomLevel
	
	# green/speed
	playerMovementSpeed = (stats["speed"] * movementSpeedMult) + baseMovementSpeed

	# blue purple/stealth
	trackableDistance = (1 - stats["stealth"]) * baseTrackableDistance

func setChromaticAbberration(on: bool) -> void:
	$FlippingSprite.use_parent_material = !on
	
func setSaturation(val: float) -> void:
	worldEnvironment.environment.adjustment_saturation = val

func startDying():
	$DeathTimer.paused = false
	$DeathTimer.start(deathTimerBaseSeconds)
	setSaturation(0.1)

func stopDying():
	$DeathTimer.stop()
	setSaturation(defaultSaturation)
	
func takeDamage(damage := 0.01) -> bool:
	var reduction = stats["damageReduction"]/500
	damage = damage - reduction
	
	var didTakeDamage = false
	if damage <= 0:
		return didTakeDamage
	
	setChromaticAbberration(true)
	$DamageEffectsTimer.start()
	
	var playerLightColor = $PlayerLight.color

	var numColorsThatCanTakeDamage := 0
	var rCanTakeDamage = playerLightColor.r > 0
	var gCanTakeDamage = playerLightColor.g > 0
	var bCanTakeDamage = playerLightColor.b > 0

	if rCanTakeDamage:
		numColorsThatCanTakeDamage += 1
		didTakeDamage = true
	if gCanTakeDamage:
		numColorsThatCanTakeDamage += 1
		didTakeDamage = true
	if bCanTakeDamage:
		numColorsThatCanTakeDamage += 1
		didTakeDamage = true
	
	if rCanTakeDamage:
		playerLightColor.r -= damage / numColorsThatCanTakeDamage
		playerLightColor.r = max(playerLightColor.r, 0)
	
	if gCanTakeDamage:
		playerLightColor.g -= damage / numColorsThatCanTakeDamage
		playerLightColor.g = max(playerLightColor.g, 0)

	if bCanTakeDamage:
		playerLightColor.b -= damage / numColorsThatCanTakeDamage
		playerLightColor.b = max(playerLightColor.b, 0)
	
	if GLOBAL_UTILS.sumColor(playerLightColor) < SUM_DAMAGE_CUTOFF:
		$DeathTimer.start()
		setSaturation(0.1)
	
	$PlayerLight.color = playerLightColor
	
	return didTakeDamage

func _process(delta):
	# handle death timer and effects
	if GLOBAL_UTILS.sumColor($PlayerLight.color) > SUM_DAMAGE_CUTOFF and $PlayerLight.enabled:
		stopDying()
	
	if $DeathTimer.is_stopped():
		if lowPassEffect.cutoff_hz <= 20000:
			lowPassEffect.cutoff_hz += 90
	elif lowPassEffect.cutoff_hz > 1000:
			lowPassEffect.cutoff_hz = 1000
	
	# # Pulse the player light
	# if $PlayerLight.enabled:
	# 	$PlayerLight.energy += getPulseTime(delta) / 100
		
	# Make the player visible if they are collecting color
	if $GravityArea.isEntityInGravityArea:
		isTrackableByEnemy = true
	else:
		isTrackableByEnemy = $PlayerLight.enabled
	
	stats = _getStatsFromColor($PlayerLight.color)
	_setAttributesFromStats()
	
	$CPUParticles2D.color = $PlayerLight.color
	
func _physics_process(_delta):
	handleInput()
	velocity = $VelocityComponent.handleExistingVelocity(self.velocity)
	move_and_slide()

func _on_damage_effects_timer_timeout() -> void:
	setChromaticAbberration(false)

func _on_death_timer_timeout() -> void:
	GameFlow.gameOver()

func rotateColorHue(amount: float) -> void:
	colorRotate.set_hue_rotation(amount)
	var rotatedColor = colorRotate.apply($PlayerLight.color)
	$PlayerLight.color = rotatedColor

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index ==  MOUSE_BUTTON_WHEEL_UP and event.pressed:
			rotateColorHue(hueRotationSpeed)
		if event.button_index ==  MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			rotateColorHue(-hueRotationSpeed)
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			$PlayerLight.color = Color.RED
