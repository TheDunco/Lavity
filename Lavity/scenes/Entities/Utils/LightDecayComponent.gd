extends Node2D

const LIGHT_DECAY_MULT := 0.10
const DECAY_THRESHOlD := 0.1


func _process(delta):
	var light: Light2D = get_parent()

	if light.enabled:
		if light.color.r > DECAY_THRESHOlD:
			light.color.r -= LIGHT_DECAY_MULT * delta
		if light.color.g > DECAY_THRESHOlD:
			light.color.g -= LIGHT_DECAY_MULT * delta
		if light.color.b > DECAY_THRESHOlD:
			light.color.b -= LIGHT_DECAY_MULT * delta
