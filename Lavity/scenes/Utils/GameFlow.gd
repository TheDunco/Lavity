extends Node2D

# Thanks to this video for the basis of this script and the naming
# https://www.youtube.com/watch?v=RMdf60IAxY0

var current_scene: Node = null
var toastText := ""

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
func switchScene(res_path: String) -> void:
	call_deferred("_deferred_switch_scene", res_path)

func _deferred_switch_scene(res_path):
	if current_scene != null:
		current_scene.free()
	var s = load(res_path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

func quit():
	get_tree().quit()

# 0.0.23 attempt
# var _stored_scene: Node = null

func _unhandled_input(event):
	if event.is_action_pressed("ui_esc"):
		## This is all very engine-specific stuff that I'm not exactly sure how to implement in Godot
		## This is kind of the idea but I'm not sure how to implement what I want here
		# if isInMenu:
		# 	if !current_scene.name == "Menu2D":
		# 		get_tree().root.remove_child(find_child("Menu", false))
		# 	isInMenu = false
		# isInMenu = true
		# get_tree().root.add_child(load("res://scenes/Ui/Menu.tscn").instantiate())

		# Perhaps a better idea than the above is to store the current scene fully in it's state,
		# then load the menu scene and the next time the player presses escape, load the stored scene

		# Implementation attempt below.
		# I think this one doesn't work solely because the _unhandled_input function is not being called in the Menu2D scene
		# Either something is handling it/it's getting eaten by some UI node, or something else is wrong with this function's logic
		# Even this isn't really what I want because I want to have the menu appear over the current scene, not replace it
		# if _stored_scene != null:
		# 	print("Loading stored scene", _stored_scene)
		# 	# current_scene = Menu2D here -- does this even work?
		# 	current_scene = _stored_scene
		# 	_stored_scene = null
		# elif current_scene.name != "Menu2D":
		# 	print("Storing current scene", current_scene)
		# 	_stored_scene = current_scene
		# 	print("Switching to menu")
		# 	switchScene("res://scenes/Ui/Menu2D.tscn")
		

		# 0.0.22
		if current_scene.name == "Menu2D":
			quit()
		switchScene("res://scenes/Ui/Menu2D.tscn")

func gameOver():
	switchScene("res://scenes/Ui/Menu2D.tscn")
