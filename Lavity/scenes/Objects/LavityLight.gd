extends Node2D
class_name LavityLight

@export var energy := 1.0
@export var MaxRgb := COLOR_UTILS.MAX_RAND_RGB
@export var randomizeColorOnReady := false
@export_color_no_alpha var initColor: Color

@onready var light = $LavityLightLight

func _ready():
	light.energy = energy
	if randomizeColorOnReady:
		light.color = COLOR_UTILS.randColor(MaxRgb)
	else:
		light.color = initColor
 
func set_energy(val: float):
	light.energy = val
