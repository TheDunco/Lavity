extends Node2D
class_name MouseLight

signal mouse_light_visible_change

func _process(delta):
	$MouseLight.position = get_global_mouse_position()
	
func _unhandled_input(event):
	if event.is_action_pressed("toggle_flashlight"):
		if $MouseLight.visible:
			$MouseLight.visible = false
			emit_signal("mouse_light_visible_change", $MouseLight.visible)
		else:
			$MouseLight.visible = true
			emit_signal("mouse_light_visible_change", $MouseLight.visible)
