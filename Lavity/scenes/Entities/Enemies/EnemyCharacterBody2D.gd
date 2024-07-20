extends CharacterBody2D
class_name Enemy

# A reference to the player so we know where to look/move
@export var player: CharacterBody2D = null
@export var Acceleration := 3.0
@export var playAnimatedSprite := true

var playerLight: PointLight2D = null

func _ready():
	if playAnimatedSprite:
		$FlippingSprite.play()
	assert(player != null)
	
	playerLight = player.find_child("PlayerLight")
	assert(playerLight != null)
	
func moveTowardPlayer():
	var directionToPlayer = global_position.direction_to(player.global_position)
	look_at(player.global_position)

	velocity += directionToPlayer * Acceleration
	velocity += directionToPlayer * Acceleration
	velocity = $VelocityComponent.handleExistingVelocity(self)
	
func _process(_delta):
	$FlippingSprite.speed_scale = $VelocityComponent.getAnimationSpeed(velocity)
	
	if playerLight.enabled:
		moveTowardPlayer()
	
	move_and_slide()
