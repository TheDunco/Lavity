extends Node2D
class_name LightDecayComponent

@export var lightDecaySlowDown := 5.0
@export var decayThreshold := 0.05

@onready var light: Light2D = get_parent()

func _process(delta): 
	if light.enabled:
		var color = light.color
		
		if light.color.r > decayThreshold:
			light.color.r -= (color.r / lightDecaySlowDown) * delta / 2
		if light.color.g > decayThreshold:
			light.color.g -= (color.g / lightDecaySlowDown) * delta / 2
		if light.color.b > decayThreshold:
			light.color.b -= (color.b / lightDecaySlowDown) * delta / 2
