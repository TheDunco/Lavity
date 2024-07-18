extends CharacterBody2D
class_name Enemy

# A reference to the player so we know where to look/move
@export var player: CharacterBody2D = null
@export var Acceleration := 3.0
@export var playAnimatedSprite := true

#TODO Componentize with one in Player
func getAnimationSpeed(velo: Vector2):
	var combinedVelocity: float = abs(velo.x) + abs(velo.y)

	if combinedVelocity > 0.0:
		return log(combinedVelocity * 100) - 7.0
	return 0.0

func _ready():
	if playAnimatedSprite:
		$FlippingSprite.play()
	assert(player != null)
	
func _process(_delta):
	var directionToPlayer = global_position.direction_to(player.global_position)
	look_at(player.global_position)
	
	$FlippingSprite.speed_scale = getAnimationSpeed(velocity)
	
	velocity += directionToPlayer * Acceleration
	velocity += directionToPlayer * Acceleration
	velocity = $VelocityComponent.handleExistingVelocity(self)
	
	move_and_slide()
