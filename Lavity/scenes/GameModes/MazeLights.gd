extends Node2D

@onready var maze: ProceduralMaze = get_parent()

@export var staticLightSpawnChance := 0.1
@export var dynamicMoteSpawnChance := 0.2

const lavityLightScene = preload('res://scenes/Objects/LavityLight.tscn')
const moteScene = preload('res://scenes/Objects/Mote.tscn')

func _ready():
	# We need an array of all of the intersections in the maze where we can spawn a LavityLight
	var mazeIntersections: Array[Vector2] = [Vector2(0,0)]
	var mazeMiddlePoints: Array[Vector2] = [Vector2(0,0)]
	for x in range(maze.width):
		for y in range(maze.height):
			mazeIntersections.append(Vector2(x * maze.tile_set.tile_size.x, y * maze.tile_set.tile_size.y))
			mazeMiddlePoints.append(Vector2(x * maze.tile_set.tile_size.x + maze.tile_set.tile_size.x / 2, y * maze.tile_set.tile_size.y + maze.tile_set.tile_size.y / 2))

	var moteCount = 0
	var lightCount = 0

	# Spawn a LavityLights
	for intersection in mazeIntersections:
		if randf() < staticLightSpawnChance:
			var lightInstance = lavityLightScene.instantiate()
			lightInstance.global_position = intersection
			lightInstance.randomizeColorOnReady = true
			lightInstance.energy = 0.5
			add_child(lightInstance)
			lightCount += 1

	for middlePoint in mazeMiddlePoints:
		if randf() < dynamicMoteSpawnChance:
			var moteInstance = moteScene.instantiate()
			moteInstance.global_position = middlePoint
			#moteInstance.initColor = COLOR_UTILS.randColor()
			add_child(moteInstance)
			moteCount += 1
	print ("Spawned " + str(lightCount) + " LavityLights and " + str(moteCount) + " Motes")
	

	
