extends Node2D
class_name ChunkNode

var chunk_coords := Vector2i()
var chunkSize: int = 0
var chunk_data = []

func start(_chunk_coords: Vector2i, chunk_size: int):
	chunk_coords = _chunk_coords
	chunkSize = chunk_size
	$Sprite2D.texture.width = chunk_size
	$Sprite2D.texture.height = chunk_size
	$Coords.text = str(chunk_coords)
	if WorldSave.loaded_coords.find(_chunk_coords) == -1:
		color()
		WorldSave.add_chunk(chunk_coords)
	else:
		chunk_data = WorldSave.retrive_data(chunk_coords)
		modulate = chunk_data[0]

func color():
	var color = ColorUtils.randColorFromSet()
	modulate = color
	chunk_data.append(color)

func save():
	WorldSave.save_chunk(chunk_coords, chunk_data)
	queue_free()
