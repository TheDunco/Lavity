extends Node2D
class_name VelocityComponent

@export var Entity: CharacterBody2D = null

@export_category("Velocity Config")
@export var speedMultiplier := 20
@export var airResistance := 5
@export var overspeedThreshold := 1000
@export var overspeedDamping := 10
@export var maxVelocity := 1500

@export_category("Sprite Effect Config")
@export var animationSpeedVeloMult := 100.0
@export var animationSpeedVeloTamingConst := 7.0

var flippingSprite: Node2D = null

func _ready():
	flippingSprite = Entity.find_child("FlippingSprite")
	assert(Entity != null)

func getAnimationSpeed(velo: Vector2):
	var combinedVelocity: float = abs(velo.x) + abs(velo.y)

	if combinedVelocity > 0.0:
		return log(combinedVelocity * animationSpeedVeloMult) - animationSpeedVeloTamingConst
	return 0.0

func handleExistingVelocity(entity: CharacterBody2D, velocity: Vector2 = entity.velocity) -> Vector2:
	var currVelocity := entity.velocity

	# Handle air resistance
	if currVelocity.x > 0 and currVelocity.x - airResistance > 0:
		velocity.x -= airResistance
	elif currVelocity.x < 0 and currVelocity.x + airResistance < 0:
		velocity.x += airResistance
		
	if velocity.y > 0 and currVelocity.y - airResistance > 0:
		velocity.y -= airResistance
	elif velocity.y < 0 and currVelocity.y + airResistance < 0:
		velocity.y += airResistance

	# Handle overspeed threshold
	if velocity.x > overspeedThreshold:
		velocity.x -= (overspeedDamping + (velocity.x - overspeedThreshold))
	elif velocity.x < - overspeedThreshold:
		velocity.x -= (overspeedDamping + (velocity.x + overspeedThreshold))

	if velocity.y > overspeedThreshold:
		velocity.y += (overspeedDamping + (velocity.y - overspeedThreshold))
	elif velocity.y < - overspeedThreshold:
		velocity.y -= - (overspeedDamping + (velocity.y + overspeedThreshold))
	
	# Handle max velocity
	if velocity.x > maxVelocity:
		velocity.x = maxVelocity
	elif velocity.x < -maxVelocity:
		velocity.x = -maxVelocity
	
	if velocity.y > maxVelocity:
		velocity.y = maxVelocity
	elif velocity.y < -maxVelocity:
		velocity.y = -maxVelocity
	
	return velocity
	
func _process(_delta):
	if flippingSprite != null:
		var rotation = Entity.rotation
		if cos(rotation) < 0:
			flippingSprite.flip_v = true
		else:
			flippingSprite.flip_v = false
