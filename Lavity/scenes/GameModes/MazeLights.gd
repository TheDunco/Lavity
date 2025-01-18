extends Node2D

@onready var maze: ProceduralMaze = get_parent()

@export var moteSpawnChance := 0.25

const moteScene = preload('res://scenes/Objects/Mote.tscn')

func _ready():
	# We need an array of all of the intersections in the maze where we can spawn a LavityLight
	var mazeMiddlePoints: Array[Vector2] = [Vector2(0,0)]
	for x in range(maze.width):
		for y in range(maze.height):
			mazeMiddlePoints.append(Vector2(x * maze.tile_set.tile_size.x + maze.tile_set.tile_size.x / 2, y * maze.tile_set.tile_size.y + maze.tile_set.tile_size.y / 2))

	var moteCount = 0

	for middlePoint in mazeMiddlePoints:
		if randf() < moteSpawnChance:
			var moteInstance = moteScene.instantiate()
			moteInstance.global_position = middlePoint
			add_child(moteInstance)
			moteInstance.setScale(moteInstance.scale * randf_range(0.25, 2.0))
			moteCount += 1
	print ("Spawned " + str(moteCount) + " Motes")
	

	
