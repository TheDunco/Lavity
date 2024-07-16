extends CharacterBody2D
class_name Enemy

@export var player: CharacterBody2D = null
@export var Acceleration := 1

func _ready():
	$FlippingSprite.play()
	assert(player != null)

func _process(_delta):
	var directionToPlayer = global_position.direction_to(player.global_position)
	look_at(directionToPlayer)
	velocity += directionToPlayer * Acceleration
	velocity += directionToPlayer * Acceleration
	move_and_slide()
