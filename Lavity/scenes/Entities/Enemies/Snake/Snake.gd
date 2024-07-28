extends CharacterBody2D

@export var player: Player = null
@export var acceleration := 4.0

func _ready():
	assert(player != null)


func _physics_process(delta):
	#var directionToPlayer = global_position.direction_to(player.global_position)
	#velocity += directionToPlayer * acceleration
	#velocity += directionToPlayer * acceleration
	#velocity = $VelocityComponent.handleExistingVelocity(self)
	$Line2D.set_point_position(0, player.global_position)
	move_and_slide()
