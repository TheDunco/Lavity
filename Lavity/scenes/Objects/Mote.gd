extends Node2D
class_name Mote

@onready var rigidBody: RigidBody2D = $OppositeForceBody
@onready var lavityLight: LavityLight = $OppositeForceBody/LavityLight
@export var repulseableDistance := 1000
@export var decayRate := 0.0

@onready var motePop = $MotePop

func _ready() -> void:
	SignalBus.connect("playerRepulsed", handlePlayerRepulsed)
	assert(decayRate < 1.0)

func handlePlayerRepulsed(playerGlobalPosition: Vector2):
	var directionToPlayer = global_position.direction_to(playerGlobalPosition)
	var distanceFromPlayer = global_position.distance_to(playerGlobalPosition)
	if distanceFromPlayer < repulseableDistance:
		var force = (repulseableDistance - distanceFromPlayer) / 10
		applyImpulse(-directionToPlayer, force)

func applyImpulse(direction: Vector2, speed: float) -> void:
	rigidBody.apply_central_impulse(direction * speed)

func changeColor(color: Color) -> void:
	lavityLight.light.color = color

func _process(delta: float) -> void:
	var blackLikeness = COLOR_UTILS.scoreColorLikeness(lavityLight.light.color, Color.BLACK)
	if decayRate > 0.0:
		lavityLight.light.color = COLOR_UTILS.takeGeneralColorDamage(lavityLight.light.color, decayRate * delta)
	if blackLikeness > 0.85:
		motePop.play()
		queue_free()
