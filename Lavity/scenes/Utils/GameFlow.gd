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

func _unhandled_input(event):
	if event.is_action_pressed("ui_esc"):
		if current_scene.name == "Menu2D":
			quit()
		switchScene("res://scenes/Ui/Menu2D.tscn")

func gameOver():
	switchScene("res://scenes/Ui/Menu2D.tscn")
