extends CharacterBody2D

const SPEED_MULT := 20
const AIR_RESISTANCE := 5
const MAX_VELOCITY := 1000
const OVERSPEED_DAMPING := 10

func handleInput():
	if Input.is_action_pressed("move_right"):
		velocity.x += SPEED_MULT
	if Input.is_action_pressed("move_left"):
		velocity.x -= SPEED_MULT
	if Input.is_action_pressed("move_up"):
		velocity.y -= SPEED_MULT
	if Input.is_action_pressed("move_down"):
		velocity.y += SPEED_MULT

func handleVelocity():
	
	handleInput()
	
	var currVelocity := velocity
	if currVelocity.x > 0 and currVelocity.x - AIR_RESISTANCE > 0:
		velocity.x -= AIR_RESISTANCE
	elif currVelocity.x < 0 and currVelocity.x + AIR_RESISTANCE < 0:
		velocity.x += AIR_RESISTANCE
		
	if velocity.y > 0 and currVelocity.y - AIR_RESISTANCE > 0:
		velocity.y -= AIR_RESISTANCE
	elif velocity.y < 0 and currVelocity.y + AIR_RESISTANCE < 0:
		velocity.y += AIR_RESISTANCE

	if velocity.x > MAX_VELOCITY:
		velocity.x -= OVERSPEED_DAMPING
	elif velocity.x < - MAX_VELOCITY:
		velocity.x -= OVERSPEED_DAMPING

	if velocity.y > MAX_VELOCITY:
		velocity.y += OVERSPEED_DAMPING
	elif velocity.y < - MAX_VELOCITY:
		velocity.y += - OVERSPEED_DAMPING
		
	print(velocity)
	
	set_velocity(velocity)

var time := 0.0
func getFlickerTime(delta):
	time += 3 * delta
	if time > 1.0e30:
		time = 0
	return sin(time)

func _process(delta):
	# Look towards the direction of travel
	if velocity.x != 0 and velocity.y != 0:
		look_at(velocity + global_position)
	$"../Camera2D".position = position

	var sprite = $Sprite2D
	if velocity.x > 0:
		sprite.flip_v = false
	elif velocity.x < 0:
		sprite.flip_v = true
		
	var flicker = getFlickerTime(delta)
	print(flicker)

	$PlayerLight.energy += flicker / 1000
	
func _physics_process(_delta):
	handleVelocity()
	move_and_slide()
