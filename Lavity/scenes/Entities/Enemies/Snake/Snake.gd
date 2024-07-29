extends CharacterBody2D
class_name Snake

@export var player: Player = null
@export var acceleration := 4.0
var pointVelocity := Vector2.ZERO

func _ready():
	assert(player != null)


func _physics_process(_delta):
	var headPos = $Line2D.get_point_position(0)
	var directionToPlayer = headPos.direction_to(player.global_position)
	if player.isTrackableByEnemy:
		pointVelocity += directionToPlayer * acceleration
		pointVelocity += directionToPlayer * acceleration

	pointVelocity = $VelocityComponent.handleExistingVelocity(self, pointVelocity)

	$Line2D.set_point_position(0, global_position + pointVelocity)
	move_and_slide()
