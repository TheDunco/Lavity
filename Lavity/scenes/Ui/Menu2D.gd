extends Node2D

func _process(delta):
	$MouseLight.position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("toggle_flashlight") and $MouseLight.energy == 0.0:
		$MouseLight.energy = 0.5
	else:
		$MouseLight.energy = 0
