extends CharacterBody2D
class_name Player

@export var worldEnvironment: WorldEnvironment

@export_category("Player Config")
@export_range(0, 2) var spriteBasePosition = 0
@export var maxZoom := 0.3
@export var lookThreshold := 50
@export var cameraBaseZoom := 1.35

@export_category("Player Stats")
@export var baseMovementSpeed := 7
@export var movementSpeedMult := 20
@export var baseTrackableDistance := 2500.0

const STEALTH_FLASHLIGHT_CUTOFF := 0.85
@export var SUM_DAMAGE_CUTOFF := 0.01

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
	$PlayerLight.color = Color(0.5, 0.5, 0.5)

func handleInput():
	var isHandlingVelocityInput := false
	if Input.is_action_pressed("move_right"):
		isHandlingVelocityInput = true
		velocity.x += playerMovementSpeed
	if Input.is_action_pressed("move_left"):
		isHandlingVelocityInput = true
		velocity.x -= playerMovementSpeed
	if Input.is_action_pressed("move_up"):
		isHandlingVelocityInput = true
		velocity.y -= playerMovementSpeed
	if Input.is_action_pressed("move_down"):
		isHandlingVelocityInput = true
		velocity.y += playerMovementSpeed
		
	if isHandlingVelocityInput:
		$FlippingSprite.speed_scale = $VelocityComponent.getAnimationSpeed(velocity)
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
	
	if Input.is_action_just_pressed("toggle_flashlight") :
		if $PlayerLight.enabled and stats["stealth"] > STEALTH_FLASHLIGHT_CUTOFF:
			$PlayerLight.enabled = false
		else:
			$PlayerLight.enabled = true

		isTrackableByEnemy = $PlayerLight.enabled
		

var time := 0.0
func getPulseTime(delta):
	time += max($FlippingSprite.speed_scale, 3) * delta
	if time > 1.0e30:
		time = 0.0
	return sin(time)
	
func _getStatsFromColor(currentColor: Color) -> Dictionary:
	var statsPerColor := {}
	
	# Figure out how similar to each color we are
	for colorName in GLOBAL_UTILS.colorNames:
		var score := GLOBAL_UTILS.scoreColorLikeness(currentColor, GLOBAL_UTILS.colors[colorName])
		statsPerColor[colorName] = score

	# Map that to the stats
	var statsToSet := {
		"damageReduction": statsPerColor["red"],
		"damage" : statsPerColor["orange"],
		"speed": statsPerColor["green"],
		"sonar": statsPerColor["blue"],
		"stealth": statsPerColor["blue_purple"],
		"vision": statsPerColor["yellow"],
		"regeneration": statsPerColor["pink"],
	}

	return statsToSet
	
func _setAttributesFromStats():
	# yellow/vision
	var zoomLevel: float = max(cameraBaseZoom - stats["vision"], maxZoom)
	$"../PlayerFollowingPhantomCam".zoom.x = zoomLevel
	$"../PlayerFollowingPhantomCam".zoom.y = zoomLevel
	
	# green/speed
	playerMovementSpeed = (stats["speed"] * movementSpeedMult) + baseMovementSpeed

	# purple/stealth
	trackableDistance = (1 - stats["stealth"]) * baseTrackableDistance

func setChromaticAbberration(on: bool) -> void:
	$FlippingSprite.use_parent_material = !on
	
func takeDamage(damage := 0.01) -> void:
	var reduction = stats["damageReduction"]/500
	damage = damage - reduction
	if damage <= 0:
		return
	
	setChromaticAbberration(true)
	$DamageEffectsTimer.start()
	
	var playerLightColor = $PlayerLight.color

	var numColorsThatCanTakeDamage := 0
	var rCanTakeDamage = playerLightColor.r > 0
	var gCanTakeDamage = playerLightColor.g > 0
	var bCanTakeDamage = playerLightColor.b > 0

	if rCanTakeDamage:
		numColorsThatCanTakeDamage += 1
	if gCanTakeDamage:
		numColorsThatCanTakeDamage += 1
	if bCanTakeDamage:
		numColorsThatCanTakeDamage += 1

	
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
		scale = Vector2(0.5, 0.4)
	
	$PlayerLight.color = playerLightColor

	
	
func _process(delta):
	if GLOBAL_UTILS.sumColor($PlayerLight.color) > SUM_DAMAGE_CUTOFF:
		scale = Vector2(1, 1)
		$DeathTimer.stop()
	
	# Look towards the direction of travel
	if abs(velocity.x) > lookThreshold or abs(velocity.y) > lookThreshold:
		look_at(velocity.normalized() + position)
		
	# Pulse the player light
	if $PlayerLight.enabled:
		$PlayerLight.energy += getPulseTime(delta) / 100
		
	# Make the player visible if they are collecting color
	if $GravityArea.isEntityInGravityArea:
		isTrackableByEnemy = true
	else:
		isTrackableByEnemy = $PlayerLight.enabled
	
	stats = _getStatsFromColor($PlayerLight.color)
	_setAttributesFromStats()
	
func _physics_process(_delta):
	handleInput()
	velocity = $VelocityComponent.handleExistingVelocity(self)
	move_and_slide()

func _on_damage_effects_timer_timeout() -> void:
	setChromaticAbberration(false)

func _on_death_timer_timeout() -> void:
	GameFlow.gameOver()
