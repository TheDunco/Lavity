extends Node2D

@onready var maze: ProceduralMaze = get_parent()
@export var maxMoteSize := 1.0

@export var moteSpawnChance := 0.33

const moteScene = preload('res://scenes/Objects/Mote.tscn')

func _ready():
	var mazeMiddlePoints: Array[Vector2] = maze.getTileCenters()
	var moteCount = 0

	for middlePoint in mazeMiddlePoints:
		if randf() < moteSpawnChance:
			var moteInstance = moteScene.instantiate()
			moteInstance.global_position = middlePoint
			add_child(moteInstance)
			moteInstance.setScale(moteInstance.scale * randf_range(0.25, maxMoteSize))
			moteCount += 1
	print ("Spawned " + str(moteCount) + " Motes")
	

	
