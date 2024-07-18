extends CharacterBody2D

@export var UserMovementSpeed := 20

#TODO Componentize with one in Doppleganger
func getAnimationSpeed(velo: Vector2):
	var combinedVelocity: float = abs(velo.x) + abs(velo.y)

	if combinedVelocity > 0.0:
		return log(combinedVelocity * 100) - 7.0
	return 0.0

func handleInput():
	var isHandlingInput := false
	if Input.is_action_pressed("move_right"):
		isHandlingInput = true
		velocity.x += UserMovementSpeed
	if Input.is_action_pressed("move_left"):
		isHandlingInput = true
		velocity.x -= UserMovementSpeed
	if Input.is_action_pressed("move_up"):
		isHandlingInput = true
		velocity.y -= UserMovementSpeed
	if Input.is_action_pressed("move_down"):
		isHandlingInput = true
		velocity.y += UserMovementSpeed
		
	if isHandlingInput:
		$FlippingSprite.speed_scale = getAnimationSpeed(velocity)
	elif $FlippingSprite.speed_scale < 0:
		$FlippingSprite.speed_scale -= 1
	else:
		$FlippingSprite.speed_scale = 0
		if $FlippingSprite.frame != 0:
			$FlippingSprite.frame -= 1

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

	$PlayerLight.energy += getPulseTime(delta) / 1000
	
func _physics_process(_delta):
	handleInput()
	velocity = $VelocityComponent.handleExistingVelocity(self)
	move_and_slide()
