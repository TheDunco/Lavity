extends Node2D
class_name LavityLight

@export var energy := 1.0
@export var MaxRgb := GLOBAL_UTILS.MAX_RGB

# Called when the node enters the scene tree for the first time.
func _ready():
	$LavityLightLight.energy = energy
	$LavityLightLight.color = GLOBAL_UTILS.randColor(MaxRgb)
 
func set_energy(val: float):
	$LavityLightLight.energy = val

func _process(_delta):
	if Input.is_action_just_pressed("change_color"):
		$LavityLightLight.color = GLOBAL_UTILS.randColor(MaxRgb)
