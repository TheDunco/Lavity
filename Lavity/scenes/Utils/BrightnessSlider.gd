extends HSlider

var canvasModulateDarkness: CanvasModulate = null
# Called when the node enters the scene tree for the first time.
func _ready():
	canvasModulateDarkness = $"../../.."

func _process(_delta):
	if Input.is_action_just_pressed("ui_esc"):
		get_tree().change_scene_to_file("res://scenes/Worlds/TestWorld.tscn")

func _on_changed():
	canvasModulateDarkness.color.a = value

