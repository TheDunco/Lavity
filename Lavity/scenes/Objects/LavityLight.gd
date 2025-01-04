extends Node2D
class_name LavityLight

@export var energy := 1.0
@export var MaxRgb := COLOR_UTILS.MAX_RAND_RGB
@export var canChangeColor := false
@export var randomizeColorOnReady := false
@export_color_no_alpha var initColor: Color

# Called when the node enters the scene tree for the first time.
func _ready():
	$LavityLightLight.energy = energy
	if randomizeColorOnReady:
		$LavityLightLight.color = COLOR_UTILS.randColor(MaxRgb)
	else:
		$LavityLightLight.color = initColor
 
func set_energy(val: float):
	$LavityLightLight.energy = val

func _unhandled_input(event):
	if event.is_action_pressed("change_color") and canChangeColor:
		$LavityLightLight.color = COLOR_UTILS.randColor(MaxRgb)
