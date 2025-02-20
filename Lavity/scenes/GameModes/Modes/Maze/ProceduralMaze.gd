extends TileMap
class_name ProceduralMaze

# Reference/source for this algorithm and most of the code
# I had to edit and adapt it (with help from the comment section) to fit into Godot 4.3
# https://youtu.be/YShYWaGF3Nc?si=CV3igxyfiqNGA_77

@export var width := 10
@export var height := 10

const tilemapSizeX := 4
const tilemapSizeY := 4

@export var source_id := 0
@export var layer := 0

const start := Vector2.ZERO

const N := 0b0001
const E := 0b0010
const S := 0b0100
const W := 0b1000

const nBitIndex = 3
const eBitIndex = 2
const sBitIndex = 1
const wBitIndex = 0

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
			set_cell(layer, Vector2i(x, y), source_id, _bitmask_to_coords(N | E | S | W))
	var current = start
	unvisited.erase(current)

	while unvisited:
		var neighbors = checkNeighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors.pick_random()
			stack.append(current)
			var direction = next - current
			var currentWalls = get_cell_atlas_coords(layer, current)
			var nextWalls = get_cell_atlas_coords(layer, next)
			set_cell(layer, current, source_id, _bitmask_to_coords(_coords_to_bitmask(currentWalls) - cellWalls[direction]))
			set_cell(layer, next, source_id, _bitmask_to_coords(_coords_to_bitmask(nextWalls) - cellWalls[-direction]))
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
	set_cell(layer, start, source_id, Vector2i(1, 2))

var tileSizeX = tile_set.tile_size.x
var tileSizeY = tile_set.tile_size.y

func getCenterPoint(x: int, y: int) -> Vector2:
	return Vector2(x * tileSizeX + tileSizeX / 2.0, y * tileSizeY + tileSizeY / 2.0)

## Returns an array of global coordinates of the tile centers
func getTileCenters() -> Array[Vector2]:
	var centers: Array[Vector2] = []
	for x in range(width):
		for y in range(height):
			centers.append(getCenterPoint(x, y))
	return centers

## Returns a matrix of the top-left of each edge peice on the maze in local tilemap coordinates:
## [north, east, south, west]
func getEdges():
	var northEdges: Array[Vector2] = []
	var eastEdges: Array[Vector2] = []
	var southEdges: Array[Vector2] = []
	var westEdges: Array[Vector2] = []
	for x in range(width):
		for y in range(height):
			if y == 0:
				northEdges.append(Vector2(x, y))
			if x == 0:
				westEdges.append(Vector2(x, y))
			if y == height - 1:
				southEdges.append(Vector2(x, y))
			if x == width - 1:
				eastEdges.append(Vector2(x, y))
				
	return [northEdges, eastEdges, southEdges, westEdges]

## Remove the wall of the cell at localCoords specified by the bitIndex
## Use the n/e/s/wBitIndex ints defined in this class
func bustDownWall(localCoords: Vector2i, bitIndex: int):
	var atlasCoords = get_cell_atlas_coords(layer, localCoords)
	var currentBitmask: int = _coords_to_bitmask(atlasCoords)

	var mask = currentBitmask ^ bitIndex
	var newBitmask = currentBitmask & mask
	var newCoords = _bitmask_to_coords(newBitmask)

	set_cell(layer, atlasCoords, source_id, newCoords)
