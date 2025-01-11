extends TileMap
class_name ProceduralMaze

# Reference/source for this algorithm and most of the code
# I had to edit and adapt it (with help from the comment section) to fit into Godot 4.3
# https://youtu.be/YShYWaGF3Nc?si=CV3igxyfiqNGA_77

@export var width := 20
@export var height := 20

const tilemapSizeX := 4
const tilemapSizeY := 4

@export var source_id := 0

const start := Vector2.ZERO

const N := 0b0001
const E := 0b0010
const S := 0b0100
const W := 0b1000

const cellWalls := {Vector2(0, -1): N, Vector2(1, 0): E, 
					Vector2(0, 1): S, Vector2(-1, 0): W}

func _bitmask_to_coords(bitmask):
	return Vector2i(int(bitmask) % int(tilemapSizeX), ceil(int(bitmask) / int(tilemapSizeY)))

func _coords_to_bitmask(coords: Vector2):
	return coords.x + coords.y * tilemapSizeY

func _ready():
	randomize()
	makeMaze()

func checkNeighbors(cell, unvisited) -> Array:
	var list = []
	for n in cellWalls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list

func makeMaze():
	var unvisited = []
	var stack = []
	self.clear()
	for x in range(width):
		for y in range(height):
			unvisited.append(Vector2(x, y))
			set_cell(0, Vector2i(x, y), source_id, _bitmask_to_coords(N|E|S|W))
	var current = start
	unvisited.erase(current)

	while unvisited:
		var neighbors = checkNeighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			var direction = next - current
			var currentWalls = get_cell_atlas_coords(0, current)
			var nextWalls = get_cell_atlas_coords(0, next) 
			set_cell(0, current, source_id, _bitmask_to_coords(_coords_to_bitmask(currentWalls) - cellWalls[direction]))
			set_cell(0, next, source_id, _bitmask_to_coords(_coords_to_bitmask(nextWalls) - cellWalls[-direction]))
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
	set_cell(0, start, source_id, Vector2i(1, 2))
