extends CharacterBody2D
class_name Enemy

# A reference to the player so we know where to look/move
@export var player: CharacterBody2D = null
@export var Acceleration := 3.0
@export var playAnimatedSprite := true

func _ready():
	if playAnimatedSprite:
		$FlippingSprite.play()
	assert(player != null)
	
func _process(_delta):
	var directionToPlayer = global_position.direction_to(player.global_position)
	look_at(player.global_position)
	velocity += directionToPlayer * Acceleration
	velocity += directionToPlayer * Acceleration
	print("Enemy velocity: ", velocity)
	velocity = $VelocityComponent.handleExistingVelocity(self)
	move_and_slide()
