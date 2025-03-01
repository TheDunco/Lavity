extends Node2D

var lanternflyScene = preload("res://scenes/Entities/Enemies/Lanternfly/Lanternfly.tscn")
var fireflyScene = preload("res://scenes/Entities/Passive/Firefly/Firefly.tscn")

@onready var maze: ProceduralMaze = get_parent()
@export var lanternflySpawnChance := 0.1
@export var fireflySpawnChance := 0.20

func _ready() -> void:
	var mazeMiddlePoints: Array[Vector2] = maze.getTileCenters()
	var lanternflyCount = 0
	var fireflyCount = 0

	for middlePoint in mazeMiddlePoints:
		lanternflyCount += GameFlow.spawnAtPoint(lanternflyScene, middlePoint, lanternflySpawnChance).size()
		fireflyCount += GameFlow.spawnAtPoint(fireflyScene, middlePoint, fireflySpawnChance).size()
	print("Spawned " + str(lanternflyCount) + " Lanternflies" + " and " + str(fireflyCount) + " Fireflies")
