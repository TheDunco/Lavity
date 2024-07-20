extends CharacterBody2D

@export var UserMovementSpeed := 20

func handleInput():
	var isHandlingVelocityInput := false
	if Input.is_action_pressed("move_right"):
		isHandlingVelocityInput = true
		velocity.x += UserMovementSpeed
	if Input.is_action_pressed("move_left"):
		isHandlingVelocityInput = true
		velocity.x -= UserMovementSpeed
	if Input.is_action_pressed("move_up"):
		isHandlingVelocityInput = true
		velocity.y -= UserMovementSpeed
	if Input.is_action_pressed("move_down"):
		isHandlingVelocityInput = true
		velocity.y += UserMovementSpeed
		
	if isHandlingVelocityInput:
		$FlippingSprite.speed_scale = $VelocityComponent.getAnimationSpeed(velocity)
	elif $FlippingSprite.speed_scale < 0:
		$FlippingSprite.speed_scale -= 1
	else:
		$FlippingSprite.speed_scale = 0
		if $FlippingSprite.frame != 0:
			$FlippingSprite.frame -= 1
	
	if Input.is_action_just_pressed("toggle_flashlight"):
		$PlayerLight.enabled = not $PlayerLight.enabled

var time := 0.0
func getPulseTime(delta):
	time += 3 * delta
	if time > 1.0e30:
		time = 0
	return sin(time)

func _process(delta):
	# Look towards the direction of travel
	if velocity.x != 0 and velocity.y != 0:
		look_at(velocity + global_position)

	if $PlayerLight.enabled:
		$PlayerLight.energy += getPulseTime(delta) / 1000
	
func _physics_process(_delta):
	handleInput()
	velocity = $VelocityComponent.handleExistingVelocity(self)
	move_and_slide()
