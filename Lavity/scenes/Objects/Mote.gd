extends Node2D
class_name Mote

#TODO: Make enemies be attracted to light so the player can distract them with motes!

@onready var rigidBody: RigidBody2D = $OppositeForceBody
@onready var lavityLight: LavityLight = $OppositeForceBody/LavityLight
@export var repulseableDistance := 1000
@export var decayRate := 0.0
@onready var pop: AudioStreamPlayer2D = $Pop

func setScale(newScale: Vector2) -> void:
	lavityLight.scale = newScale
	
func getLightColor() -> Color:
	return lavityLight.light.color

func _ready() -> void:
	SignalBus.connect("playerRepulsed", handlePlayerRepulsed)
	assert(decayRate < 1.0)

func handlePlayerRepulsed(playerGlobalPosition: Vector2):
	var directionToPlayer = global_position.direction_to(playerGlobalPosition)
	var distanceToPlayer = global_position.distance_to(playerGlobalPosition)
	if distanceToPlayer < repulseableDistance:
		#TODO: Expected behavior: closer to the player you are the more force
		var force = repulseableDistance / 10
		applyImpulse(-directionToPlayer, force)

func applyImpulse(direction: Vector2, speed: float) -> void:
	rigidBody.apply_central_impulse(direction * speed)

func changeColor(color: Color) -> void:
	lavityLight.light.color = color

func _process(delta: float) -> void:
	var blackLikeness = ColorUtils.scoreColorLikeness(lavityLight.light.color, Color.BLACK)
	if decayRate > 0.0:
		lavityLight.light.color = ColorUtils.takeGeneralColorDamage(lavityLight.light.color, decayRate * delta)
	if blackLikeness > 0.80:
		SignalBus.emit_signal("moteFreeing", self)
		queue_free()
