extends Control
class_name Menu

const settings_save_path = "user://settings.save"

# Main Menu
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/Worlds/TestWorld.tscn")

func _on_options_pressed():
	$Options.show()
	$AspectRatioContainer.hide()

func _on_quit_pressed():
	get_tree().quit()
	
# Options
func _on_options_back_pressed():
	$Options.hide()
	$AspectRatioContainer.show()
	

func _on_brightness_slider_value_changed(value):
	pass
