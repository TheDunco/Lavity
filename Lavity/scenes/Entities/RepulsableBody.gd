extends CharacterBody2D
class_name RepulsableBody

func handlePlayerRepulsed(playerGlobalPosition: Vector2):
	var distanceFromPlayer = global_position.distance_to(playerGlobalPosition)
	if distanceFromPlayer < 1000:
		var directionToPlayer = global_position.direction_to(playerGlobalPosition)
		velocity += -directionToPlayer * 1500

func _ready() -> void:
	SignalBus.connect("playerRepulsed", handlePlayerRepulsed)