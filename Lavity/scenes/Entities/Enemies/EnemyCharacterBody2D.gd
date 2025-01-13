extends CharacterBody2D
class_name Enemy

# A reference to the player so we know where to look/move
@export var player: Player = null
@export var Acceleration := 25.0
@export var playAnimatedSprite := true

@export var damageMult := 0.01

var prevDistanceToPlayer := 0.0

func handlePlayerRepulsed(playerGlobalPosition: Vector2):
	var distanceFromPlayer = global_position.distance_to(playerGlobalPosition)
	if distanceFromPlayer < 1000:
		var directionToPlayer = global_position.direction_to(playerGlobalPosition)
		velocity += -directionToPlayer * Acceleration * 100

func _ready():
	if playAnimatedSprite:
		$FlippingSprite.play()
	assert(player != null)
	SignalBus.connect("playerRepulsed", handlePlayerRepulsed)
	
func moveTowardPlayer(distanceToPlayer: float):
	var directionToPlayer = global_position.direction_to(player.global_position)
	look_at(player.global_position)
	
	var contextualAccelerationSlowdown = 0

	if prevDistanceToPlayer < distanceToPlayer:
		contextualAccelerationSlowdown = Acceleration * 0.5

	velocity += directionToPlayer * (Acceleration - contextualAccelerationSlowdown)
	velocity = $VelocityComponent.handleExistingVelocity(self.velocity)
	
func _process(_delta):
	$FlippingSprite.speed_scale = $VelocityComponent.getAnimationSpeed(velocity)

func _physics_process(_delta):
	var distanceToPlayer: float = global_position.distance_to(player.global_position)
	if player.isTrackableByEnemy and distanceToPlayer < player.trackableDistance:
		moveTowardPlayer(distanceToPlayer)
	
	prevDistanceToPlayer = distanceToPlayer
	move_and_slide()
