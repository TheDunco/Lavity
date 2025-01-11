extends Node2D

@onready var maze: ProceduralMaze = get_parent()

@export var lightSpawnChance := 0.1

const lavityLightScene = preload('res://scenes/Objects/LavityLight.tscn')

func _ready():
	# We need an array of all of the intersections in the maze where we can spawn a LavityLight
	var mazeIntersections: Array[Vector2] = [Vector2(0,0)]
	for x in range(maze.width):
		for y in range(maze.height):
			mazeIntersections.append(Vector2(x * maze.tile_set.tile_size.x, y * maze.tile_set.tile_size.y))

	# We will now iterate through the mazeIntersections array and spawn a LavityLight at each intersection with a chance of lightSpawnChance
	for intersection in mazeIntersections:
		if randf() < lightSpawnChance:
			var lightInstance = lavityLightScene.instantiate()
			lightInstance.global_position = intersection
			lightInstance.initColor = COLOR_UTILS.randColor()
			lightInstance.energy = 0.5
			add_child(lightInstance)
