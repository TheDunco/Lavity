extends CharacterBody2D

@export var UserMovementSpeed := 20

func handleInput():
	if Input.is_action_pressed("move_right"):
		velocity.x += UserMovementSpeed
	if Input.is_action_pressed("move_left"):
		velocity.x -= UserMovementSpeed
	if Input.is_action_pressed("move_up"):
		velocity.y -= UserMovementSpeed
	if Input.is_action_pressed("move_down"):
		velocity.y += UserMovementSpeed

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
