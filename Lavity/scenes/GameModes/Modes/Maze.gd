extends Node2D
class_name MazeMode

@onready var background := $Background
@onready var tilemap := $ProceduralMazeTilemap

@export var margins = 100

func _ready() -> void:
	background.texture.width = tilemap.width * tilemap.tile_set.tile_size.x + margins
	background.texture.height = tilemap.height * tilemap.tile_set.tile_size.y + margins
