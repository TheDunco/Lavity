extends Node2D
class_name VelocityComponent

@export var Entity: CharacterBody2D = null

@export_category("Velocity Config")
@export var speedMultiplier := 20
@export var airResistance := 5
@export var overspeedThreshold := 1000
@export var maxVelocity := 1500

@export_category("Sprite Effect Config")
@export var animationSpeedVeloMult := 100.0
@export var animationSpeedVeloTamingConst := 7.0

func _ready():
	assert(Entity != null)

func getAnimationSpeed(velo: Vector2):
	var combinedVelocity: float = abs(velo.x) + abs(velo.y)

	if combinedVelocity > 0.0:
		return log(combinedVelocity * animationSpeedVeloMult) - animationSpeedVeloTamingConst
	return 0.0

func handleExistingVelocity(velocity: Vector2) -> Vector2:
	var currVelocity := velocity

	# Handle max velocity
	if currVelocity.x > maxVelocity:
		currVelocity.x = maxVelocity - 1.0
	elif currVelocity.x < -maxVelocity:
		currVelocity.x = -maxVelocity + 1.0
	
	if currVelocity.y > maxVelocity:
		currVelocity.y = maxVelocity - 1.0
	elif currVelocity.y < -maxVelocity:
		currVelocity.y = -maxVelocity + 1.0

	# Handle air resistance
	if currVelocity.x > 0 and currVelocity.x - airResistance > 0:
		currVelocity.x -= airResistance
	elif currVelocity.x < 0 and currVelocity.x + airResistance < 0:
		currVelocity.x += airResistance
		
	if currVelocity.y > 0 and currVelocity.y - airResistance > 0:
		currVelocity.y -= airResistance
	elif currVelocity.y < 0 and currVelocity.y + airResistance < 0:
		currVelocity.y += airResistance
	
	return currVelocity
	
func _process(_delta):
	var curScaleY = Entity.scale.y
	var rotationCos = cos(Entity.rotation)
	if rotationCos < 0 and curScaleY > 0:
		Entity.scale.y = -Entity.scale.y
	elif rotationCos > 0 and curScaleY < 0:
		Entity.scale = Vector2(Entity.scale.x, abs(Entity.scale.y))
