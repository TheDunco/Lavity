extends Control

func _on_ready():
	$Light.play()
	

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/Ui/Menu.tscn")
