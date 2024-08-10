extends CharacterBody2D
class_name Enemy

# A reference to the player so we know where to look/move
@export var player: Player = null
@export var Acceleration := 3.0
@export var playAnimatedSprite := true

@export var damageMult := 0.01

func _ready():
	if playAnimatedSprite:
		$FlippingSprite.play()
	assert(player != null)
	
func moveTowardPlayer():
	var directionToPlayer = global_position.direction_to(player.global_position)
	look_at(player.global_position)

	velocity += directionToPlayer * Acceleration
	velocity += directionToPlayer * Acceleration
	velocity = $VelocityComponent.handleExistingVelocity(self)
	
func _process(_delta):
	$FlippingSprite.speed_scale = $VelocityComponent.getAnimationSpeed(velocity)

func _physics_process(_delta):
	var distanceToPlayer = global_position.distance_to(player.global_position)
	if player.isTrackableByEnemy and distanceToPlayer < player.trackableDistance:
		moveTowardPlayer()
	
	move_and_slide()
