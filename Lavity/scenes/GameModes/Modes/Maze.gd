extends Node2D
class_name MazeMode

@onready var background: Sprite2D = $Background
@onready var tilemap: ProceduralMaze = $ProceduralMazeTilemap
@onready var cam := $PlayerFollowingPhantomCam

func _ready() -> void:
	var width = tilemap.width * tilemap.tile_set.tile_size.x
	var height = tilemap.height * tilemap.tile_set.tile_size.y

	background.texture.width = tilemap.tile_set.tile_size.x
	background.texture.height = tilemap.tile_set.tile_size.y
	background.scale = Vector2(width, height)

	cam.limit_left = 0
	cam.limit_right = tilemap.width * tilemap.tile_set.tile_size.x
	cam.limit_top = 0
	cam.limit_bottom = tilemap.height * tilemap.tile_set.tile_size.y
