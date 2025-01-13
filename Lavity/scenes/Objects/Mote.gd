extends Node2D
class_name Mote

@onready var rigidBody = $RigidBody2D
@export var repulseableDistance := 1000

func _ready() -> void:
	SignalBus.connect("playerRepulsed", handlePlayerRepulsed)

func handlePlayerRepulsed(playerGlobalPosition: Vector2):
	var directionToPlayer = global_position.direction_to(playerGlobalPosition)
	var distanceFromPlayer = global_position.distance_to(playerGlobalPosition)
	if distanceFromPlayer < repulseableDistance:
		var force = (repulseableDistance - distanceFromPlayer) / 10
		print("force", force)
		rigidBody.apply_central_impulse(-directionToPlayer * force)
