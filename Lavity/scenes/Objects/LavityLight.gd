extends Node2D

@export var energy := 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$LavityLightLight.energy = energy
 
