extends Node2D
class_name LavityLight

@export var energy := 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$LavityLightLight.energy = energy
 
func set_energy(val: float):
	$LavityLightLight.energy = val
