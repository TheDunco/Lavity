extends CharacterBody2D
class_name RepulsableBody

@export var acceleration := 25.0
@export_range(10.0, 100.0) var bounceMult: float = acceleration

func handlePlayerRepulsed(playerGlobalPosition: Vector2):
	var distanceFromPlayer = global_position.distance_to(playerGlobalPosition)
	if distanceFromPlayer < 1000:
		var directionToPlayer = global_position.direction_to(playerGlobalPosition)
		velocity += -directionToPlayer * 1500

func moveToward(pos: Vector2, accel: float = acceleration) -> void:
	velocity += global_position.direction_to(pos) * (accel + (global_position.distance_to(pos) * (1 / 100)))

func _ready() -> void:
	SignalBus.connect("playerRepulsed", handlePlayerRepulsed)