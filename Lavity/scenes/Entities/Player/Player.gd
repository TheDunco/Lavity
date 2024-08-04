extends CharacterBody2D
class_name Player

@export_range(0, 2) var spriteBasePosition = 0

var stats := {}
var playerMovementSpeed := 20
# TODO: Switch this to be a number representing the range at which the player can be seen by enemies thereby implementing stealth
var isTrackableByEnemy: bool = true

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
	
func _setAttributesFromStats():
	# TODO: Vision should affect the WorldEnvironmen/CanvasModulate and not the size of the lavity light
	# yellow/vision
	$PlayerLight.scale.x = stats["vision"]
	$PlayerLight.scale.y = stats["vision"]
	
	# green/speed
	playerMovementSpeed = stats["speed"] * 20
	

func _process(delta):
	# Look towards the direction of travel
	if abs(velocity.x) > 0.1 and abs(velocity.y) > 0.1:
		look_at(velocity + global_position)
		
	# Pulse the player light
	if $PlayerLight.enabled:
		$PlayerLight.energy += getPulseTime(delta) / 100
	if $GravityArea.isEntityInGravityArea:
		isTrackableByEnemy = true
	else:
		isTrackableByEnemy = $PlayerLight.enabled
	
	stats = GLOBAL_UTILS.getStatsFromColor($PlayerLight.color)
	_setAttributesFromStats()
	
func _physics_process(_delta):
	handleInput()
	velocity = $VelocityComponent.handleExistingVelocity(self)
	move_and_slide()
	
