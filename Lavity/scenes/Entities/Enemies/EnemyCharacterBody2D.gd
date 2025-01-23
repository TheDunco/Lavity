extends CharacterBody2D
class_name Enemy

@export var acceleration := 25.0
@export var playAnimatedSprite := true

@onready var flippingSprite := $FlippingSprite
@onready var velocityComponent: VelocityComponent = $VelocityComponent

@export var damageMult := 0.01

var prevDistanceToPlayer := 0.0

enum EnemyType {
	BUG,
	AMPHIBIAN
}
var type: EnemyType = EnemyType.BUG
# TODO: Should be static per enemy type?, random for testing
var preferredMoteColor = COLOR_UTILS.randColorFromSet()

func handlePlayerRepulsed(playerGlobalPosition: Vector2):
	var distanceFromPlayer = global_position.distance_to(playerGlobalPosition)
	if distanceFromPlayer < 1000:
		var directionToPlayer = global_position.direction_to(playerGlobalPosition)
		velocity += -directionToPlayer * 1000

func _ready():
	if playAnimatedSprite:
		flippingSprite.play()
	SignalBus.connect("playerRepulsed", handlePlayerRepulsed)
	
	
func _process(_delta):
	flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(velocity)
