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

var colorRotate = COLOR_UTILS.RGBRotate.new()

@export_category("Player Stats")
@export var baseStatsMult := 1.0
@export var baseMovementSpeed := 10
@export var movementSpeedMult := 20
@export var baseTrackableDistance := 5000.0

@export var STEALTH_FLASHLIGHT_CUTOFF := 0.82
@export var SUM_DAMAGE_CUTOFF := 0.03

@onready var reverbBusIndex := AudioServer.get_bus_index("ReverbBus")
@onready var lowPassEffect: AudioEffectLowPassFilter = AudioServer.get_bus_effect(reverbBusIndex, 1)

@onready var playerLight = $PlayerLight
@onready var flippingSprite = $FlippingSprite
@onready var velocityComponent = $VelocityComponent
@onready var deathTimer = $DeathTimer
@onready var cam: PhantomCamera2D = $"../PlayerFollowingPhantomCam"

var repulseTime = 0.0
const repulseActiveTime := 3.0 
@onready var initEnergy = playerLight.energy

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
	playerLight.color = Color.RED

func handleKeyboardInput():
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
		velocityComponent.bypassAutoOrientation = !velocityComponent.bypassAutoOrientation
		
	if Input.is_action_just_pressed("toggle_flashlight") :
		if playerLight.enabled:# and stats["stealth"] > STEALTH_FLASHLIGHT_CUTOFF:
			playerLight.enabled = false
			startDying()
		else:
			playerLight.enabled = true
			stopDying()

		isTrackableByEnemy = playerLight.enabled
	
	if isLocked:
		#velocityComponent.bypassAutoOrientation = true
		if isOnCeiling or isOnFloor:
			velocity.y = 0
	else:
		#velocityComponent.bypassAutoOrientation = false
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

var time := 0.0
func getPulseTime(delta):
	time += max(flippingSprite.speed_scale, 3) * delta
	if time > 1.0e30:
		time = 0.0
	return sin(time)
	
func getLightColor() -> Color:
	return playerLight.color

func _getStatsFromColor(currentColor: Color) -> Dictionary:
	var statsToSet := {
		"damageReduction": COLOR_UTILS.scoreColorLikeness(currentColor, COLOR_UTILS.colors["red"]) * baseStatsMult,
		"damage" : COLOR_UTILS.scoreColorLikeness(currentColor, COLOR_UTILS.colors["orange"]) * baseStatsMult,
		"speed": COLOR_UTILS.scoreColorLikeness(currentColor, COLOR_UTILS.colors["green"]) * baseStatsMult,
		"sonar": COLOR_UTILS.scoreColorLikeness(currentColor, COLOR_UTILS.colors["blue"]) * baseStatsMult,
		"stealth": COLOR_UTILS.scoreColorLikeness(currentColor, COLOR_UTILS.colors["blue_purple"]) * baseStatsMult,
		"vision": COLOR_UTILS.scoreColorLikeness(currentColor, COLOR_UTILS.colors["yellow"]) * baseStatsMult,
		"regeneration": COLOR_UTILS.scoreColorLikeness(currentColor, COLOR_UTILS.colors["pink"]) * baseStatsMult,
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

func setChromaticAbberration(on: bool) -> void:
	flippingSprite.use_parent_material = !on
	
func setSaturation(val: float) -> void:
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
	
func takeDamage(damage := 0.01) -> bool:
	var reduction = stats["damageReduction"]/500
	damage = damage - reduction
	
	var didTakeDamage = false
	if damage <= 0:
		return didTakeDamage
	
	setChromaticAbberration(true)
	$DamageEffectsTimer.start()
	
	var newPlayerLightColor = playerLight.color

	var numColorsThatCanTakeDamage := 0
	var rCanTakeDamage = newPlayerLightColor.r > 0
	var gCanTakeDamage = newPlayerLightColor.g > 0
	var bCanTakeDamage = newPlayerLightColor.b > 0

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
		newPlayerLightColor.r -= damage / numColorsThatCanTakeDamage
		newPlayerLightColor.r = max(newPlayerLightColor.r, 0)
	
	if gCanTakeDamage:
		newPlayerLightColor.g -= damage / numColorsThatCanTakeDamage
		newPlayerLightColor.g = max(newPlayerLightColor.g, 0)

	if bCanTakeDamage:
		newPlayerLightColor.b -= damage / numColorsThatCanTakeDamage
		newPlayerLightColor.b = max(newPlayerLightColor.b, 0)
	
	playerLight.color = newPlayerLightColor
	
	return didTakeDamage

func _process(delta):
	# handle death timer and effects
	var playerDying = COLOR_UTILS.sumColor(playerLight.color) < SUM_DAMAGE_CUTOFF or not playerLight.enabled
	if not playerDying:
		stopDying()
	elif deathTimer.is_stopped():
		startDying(true)

	takeDamage(0.0001)
	
	
	if deathTimer.is_stopped():
		if lowPassEffect.cutoff_hz <= 20000:
			lowPassEffect.cutoff_hz += 90
	elif lowPassEffect.cutoff_hz > 1000:
			lowPassEffect.cutoff_hz = 1000
		
	# Make the player visible if they are collecting color
	if $GravityArea.isEntityInGravityArea:
		isTrackableByEnemy = true
	else:
		isTrackableByEnemy = playerLight.enabled
	
	stats = _getStatsFromColor(playerLight.color)
	_setAttributesFromStats()

	if repulseTime > 0.0:
		repulseTime -= delta
	if repulseTime > initEnergy:
		playerLight.energy = repulseTime + 0.3
	
	GlobalDynamicMusicComponent.setDynamicTrackVolume(playerLight.color)
	
func _physics_process(_delta):
	handleKeyboardInput()
	velocity = velocityComponent.handleExistingVelocity(self.velocity)
	# TODO: Mote impulse
	# var overlappingAreas = get_overlapping_areas()
	move_and_slide()

func _on_damage_effects_timer_timeout() -> void:
	setChromaticAbberration(false)

func _on_death_timer_timeout() -> void:
	GameFlow.gameOver()

func rotateColorHue(amount: float) -> void:
	colorRotate.set_hue_rotation(amount)
	var rotatedColor = colorRotate.apply(playerLight.color)
	playerLight.color = rotatedColor


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index ==  MOUSE_BUTTON_WHEEL_UP and event.pressed:
			rotateColorHue(hueRotationSpeed)
		if event.button_index ==  MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			rotateColorHue(-hueRotationSpeed)
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			playerLight.color = COLOR_UTILS.YELLOW
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if COLOR_UTILS.scoreColorLikeness(playerLight.color, Color.WHITE) > 0.15 and repulseTime <= 0.0:
				playerLight.color -= Color(0.07, 0.07, 0.07, 0.0)
				GlobalSfx.playRepulse()
				SignalBus.playerRepulsed.emit()
				repulseTime = 2.5
