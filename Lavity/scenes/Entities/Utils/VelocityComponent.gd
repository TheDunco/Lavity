extends Node2D

@export var Entity: CharacterBody2D = null

@export var SpeedMultiplier := 20
@export var AirResistance := 5
@export var MaxVelocity := 1000
@export var OverspeedDamping := 10

func _ready():
	assert(Entity != null)

func handleExistingVelocity():
	var currVelocity := Entity.velocity
	var velocity := Entity.velocity
	if currVelocity.x > 0 and currVelocity.x - AirResistance > 0:
		velocity.x -= AirResistance
	elif currVelocity.x < 0 and currVelocity.x + AirResistance < 0:
		velocity.x += AirResistance
		
	if velocity.y > 0 and currVelocity.y - AirResistance > 0:
		velocity.y -= AirResistance
	elif velocity.y < 0 and currVelocity.y + AirResistance < 0:
		velocity.y += AirResistance

	if velocity.x > MaxVelocity:
		velocity.x -= (OverspeedDamping + (velocity.x - MaxVelocity))
	elif velocity.x < - MaxVelocity:
		velocity.x -= (OverspeedDamping + (velocity.x + MaxVelocity))

	if velocity.y > MaxVelocity:
		velocity.y += (OverspeedDamping + (velocity.y - MaxVelocity))
	elif velocity.y < - MaxVelocity:
		velocity.y += - (OverspeedDamping + (velocity.y + MaxVelocity))
	return velocity
		
func _process_physics():
	Entity.velocity = handleExistingVelocity()
	
	var flippingSprite = Entity.find_child("FlippingSprite")
	
	print("FlippingSprite", flippingSprite)
	if Entity.velocity.x > 0:
		flippingSprite.flip_v = false
		flippingSprite.flip_v = false
	elif Entity.velocity.x < 0:
		flippingSprite.flip_v = true
		flippingSprite.flip_v = true
		
	Entity.move_and_slide()
