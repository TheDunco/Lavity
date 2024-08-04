extends CharacterBody2D
class_name Player

@export var worldEnvironment: WorldEnvironment

@export_range(0, 2) var spriteBasePosition = 0
@export var maxZoom := 0.3
@export var lookThreshold := 50
@export var baseMovementSpeed := 7

var stats := {
	"health": 0.5,
	"damage" : 0.5,
	"speed": 0.5,
	"sonar": 0.5,
	"stealth": 0.5,
	"vision": 0.5,
	"regeneration": 0.5,
}

var playerMovementSpeed := 20
# TODO: Switch this to be a number representing the range at which the player can be seen by enemies thereby implementing stealth
var isTrackableByEnemy: bool = true

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
	
	if Input.is_action_just_pressed("toggle_flashlight"):
		$PlayerLight.enabled = not $PlayerLight.enabled
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
		"health": statsPerColor["red"],
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
	var zoomLevel: float = max(1.35 - stats["vision"], maxZoom)
	$"../PlayerFollowingPhantomCam".zoom.x = zoomLevel
	$"../PlayerFollowingPhantomCam".zoom.y = zoomLevel
	
	# green/speed
	playerMovementSpeed = (stats["speed"] * 20) + baseMovementSpeed
	
func _process(delta):
	# Look towards the direction of travel
	if abs(velocity.x) > lookThreshold or abs(velocity.y) > lookThreshold:
		look_at(velocity.normalized() + position)
		
	# Pulse the player light
	if $PlayerLight.enabled:
		$PlayerLight.energy += getPulseTime(delta) / 100
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
	
