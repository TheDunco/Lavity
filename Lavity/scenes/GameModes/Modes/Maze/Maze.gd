extends Node2D
class_name MazeMode

@onready var tilemap: ProceduralMaze = $ProceduralMazeTilemap
@onready var cam := $PlayerFollowingPhantomCam

func _ready() -> void:
	cam.limit_left = 0
	cam.limit_right = tilemap.width * tilemap.tile_set.tile_size.x
	cam.limit_top = 0
	cam.limit_bottom = tilemap.height * tilemap.tile_set.tile_size.y

	SignalBus.emit_signal("displayHeroText", "[center]\n[wave]Objective[/wave]: Find the portal to escape the maze[/center]")
