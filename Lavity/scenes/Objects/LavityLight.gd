extends Node2D
class_name LavityLight

@export var energy := 1.0
@export var MaxRgb := ColorUtils.MAX_RAND_RGB
@export var randomizeColorOnReady := false
@export_color_no_alpha var initColor: Color

@onready var light = $LavityLightLight

func _ready():
	light.energy = energy
	if randomizeColorOnReady:
		light.color = ColorUtils.randColor(MaxRgb)
	else:
		light.color = initColor
 
func set_energy(val: float):
	light.energy = val
