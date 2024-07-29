extends Node2D

@export var Entity: CharacterBody2D = null

@export var speedMultiplier := 20
@export var airResistance := 5
@export var maxVelocity := 1000
@export var overspeedDamping := 10

var flippingSprite: Node2D = null

func _ready():
	flippingSprite = Entity.find_child("FlippingSprite")
	assert(Entity != null)

func getAnimationSpeed(velo: Vector2):
	var combinedVelocity: float = abs(velo.x) + abs(velo.y)

	if combinedVelocity > 0.0:
		return log(combinedVelocity * 100) - 7.0
	return 0.0

func handleExistingVelocity(entity: CharacterBody2D, velocity: Vector2 = entity.velocity):
	var currVelocity := entity.velocity

	if currVelocity.x > 0 and currVelocity.x - airResistance > 0:
		velocity.x -= airResistance
	elif currVelocity.x < 0 and currVelocity.x + airResistance < 0:
		velocity.x += airResistance
		
	if velocity.y > 0 and currVelocity.y - airResistance > 0:
		velocity.y -= airResistance
	elif velocity.y < 0 and currVelocity.y + airResistance < 0:
		velocity.y += airResistance

	if velocity.x > maxVelocity:
		velocity.x -= (overspeedDamping + (velocity.x - maxVelocity))
	elif velocity.x < - maxVelocity:
		velocity.x -= (overspeedDamping + (velocity.x + maxVelocity))

	if velocity.y > maxVelocity:
		velocity.y += (overspeedDamping + (velocity.y - maxVelocity))
	elif velocity.y < - maxVelocity:
		velocity.y += - (overspeedDamping + (velocity.y + maxVelocity))
	return velocity
	
func _process(_delta):
	if flippingSprite != null:
		if Entity.velocity.x > 0:
			flippingSprite.flip_v = false
			flippingSprite.flip_v = false
		elif Entity.velocity.x < 0:
			flippingSprite.flip_v = true
			flippingSprite.flip_v = true
