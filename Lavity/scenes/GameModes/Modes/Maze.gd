extends Node2D
class_name MazeMode

@onready var background := $Background
@onready var tilemap := $ProceduralMazeTilemap
@onready var cam := $PlayerFollowingPhantomCam

@export var margins = 100

func _ready() -> void:
	background.texture.width = tilemap.width * tilemap.tile_set.tile_size.x + margins
	background.texture.height = tilemap.height * tilemap.tile_set.tile_size.y + margins

	cam.limit_left = 0
	cam.limit_right = tilemap.width * tilemap.tile_set.tile_size.x
	cam.limit_top = 0
	cam.limit_bottom = tilemap.height * tilemap.tile_set.tile_size.y
