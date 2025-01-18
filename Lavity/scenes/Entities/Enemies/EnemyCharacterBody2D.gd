extends CharacterBody2D
class_name Enemy

# A reference to the player so we know where to look/move
@export var player: Player = null
@export var acceleration := 25.0
@export var playAnimatedSprite := true

@onready var flippingSprite := $FlippingSprite
@onready var velocityComponent := $VelocityComponent

@export var damageMult := 0.01

var prevDistanceToPlayer := 0.0

func handlePlayerRepulsed(playerGlobalPosition: Vector2):
	var distanceFromPlayer = global_position.distance_to(playerGlobalPosition)
	if distanceFromPlayer < 1000:
		var directionToPlayer = global_position.direction_to(playerGlobalPosition)
		velocity += -directionToPlayer * acceleration * 100

func _ready():
	if playAnimatedSprite:
		flippingSprite.play()
	assert(player != null)
	SignalBus.connect("playerRepulsed", handlePlayerRepulsed)
	
func moveTowardPlayer(distanceToPlayer: float):
	var directionToPlayer = global_position.direction_to(player.global_position)
	look_at(player.global_position)
	
	var contextualAccelerationSlowdown = 0

	if prevDistanceToPlayer < distanceToPlayer:
		contextualAccelerationSlowdown = acceleration * 0.5

	velocity += directionToPlayer * (acceleration - contextualAccelerationSlowdown)
	velocity = velocityComponent.handleExistingVelocity(self.velocity)
	
func _process(_delta):
	flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(velocity)

func _physics_process(_delta):
	var distanceToPlayer: float = global_position.distance_to(player.global_position)
	if player.isTrackableByEnemy and distanceToPlayer < player.trackableDistance:
		moveTowardPlayer(distanceToPlayer)
	
	prevDistanceToPlayer = distanceToPlayer
	move_and_slide()
