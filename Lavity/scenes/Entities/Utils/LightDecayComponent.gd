extends Node2D
class_name LightDecayComponent

@export var ligthDecayMult := 0.02
@export var decayThreshold := 0.05

@onready var light: Light2D = get_parent()

func _process(delta):
	if light.enabled:
		if light.color.r > decayThreshold:
			light.color.r -= ligthDecayMult * delta
		if light.color.g > decayThreshold:
			light.color.g -= ligthDecayMult * delta
		if light.color.b > decayThreshold:
			light.color.b -= ligthDecayMult * delta
