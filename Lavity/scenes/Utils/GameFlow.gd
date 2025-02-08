extends Node2D

# Thanks to this video for the basis of this script and the naming
# https://www.youtube.com/watch?v=RMdf60IAxY0

var current_scene: Node = null
var heroText := "[center]\n\n\nWelcome to...[/center]"
const gameOverText := "[center][wave]Game Over![/wave] You need light to survive![/center]"

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
func switchScene(res_path: String) -> void:
	for mote in get_tree().get_nodes_in_group("motes"):
		mote.queue_free()
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

func gameOver():
	switchScene("res://scenes/Ui/Menu2D.tscn")
	heroText = gameOverText
	SignalBus.emit_signal("displayHeroText", gameOverText)


# TODO: The current song somehow needs to be more global for this to work right 
# Perhaps instead of signals, use a global var and just change it. Nothing else needs to know that the song changed
func switchToDynamicMusic():
	GlobalDynamicMusicComponent.enable()
	MusicComponent.pause()
	MusicComponent.songChanged.emit("Polychrome")

func switchToMenuMusic():
	GlobalDynamicMusicComponent.disable()
	MusicComponent.resume()
	MusicComponent.songChanged.emit(MusicComponent.musicRotation[MusicComponent.currentIndex].name)
