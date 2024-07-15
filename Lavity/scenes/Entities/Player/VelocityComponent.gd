extends Node2D

@export var Entity: CharacterBody2D

@export var SPEED_MULT := 20
@export var AIR_RESISTANCE := 5
@export var MAX_VELOCITY := 1000
@export var OVERSPEED_DAMPING := 10

func handleExistingVelocity():
	var currVelocity := Entity.velocity
	var velocity := Entity.velocity
	if currVelocity.x > 0 and currVelocity.x - AIR_RESISTANCE > 0:
		velocity.x -= AIR_RESISTANCE
	elif currVelocity.x < 0 and currVelocity.x + AIR_RESISTANCE < 0:
		velocity.x += AIR_RESISTANCE
		
	if velocity.y > 0 and currVelocity.y - AIR_RESISTANCE > 0:
		velocity.y -= AIR_RESISTANCE
	elif velocity.y < 0 and currVelocity.y + AIR_RESISTANCE < 0:
		velocity.y += AIR_RESISTANCE

	if velocity.x > MAX_VELOCITY:
		velocity.x -= (OVERSPEED_DAMPING + (velocity.x - MAX_VELOCITY))
	elif velocity.x < - MAX_VELOCITY:
		velocity.x -= (OVERSPEED_DAMPING + (velocity.x + MAX_VELOCITY))

	if velocity.y > MAX_VELOCITY:
		velocity.y += (OVERSPEED_DAMPING + (velocity.y - MAX_VELOCITY))
	elif velocity.y < - MAX_VELOCITY:
		velocity.y += - (OVERSPEED_DAMPING + (velocity.y + MAX_VELOCITY))
	return velocity
		
func _process_physics():
	Entity.set_veloicty(handleExistingVelocity())
	Entity.move_and_slide()
