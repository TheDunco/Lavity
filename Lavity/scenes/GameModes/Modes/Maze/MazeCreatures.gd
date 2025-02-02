extends Node2D

var lanternflyScene = preload("res://scenes/Entities/Enemies/Lanternfly/Lanternfly.tscn")
var fireflyScene = preload("res://scenes/Entities/Passive/Firefly/Firefly.tscn")

@onready var maze: ProceduralMaze = get_parent()
@export var lanternflySpawnChance := 0.1
@export var fireflySpawnChance := 0.15

func spawnAtPoint(scene: PackedScene, point: Vector2, spawnChance: float):
	if randf() < spawnChance:
		var instance = scene.instantiate()
		instance.global_position = point
		add_child(instance)
		return 1
	return 0

func _ready() -> void:
	var mazeMiddlePoints: Array[Vector2] = maze.getTileCenters()
	var lanternflyCount = 0
	var fireflyCount = 0

	for middlePoint in mazeMiddlePoints:
		lanternflyCount += spawnAtPoint(lanternflyScene, middlePoint, lanternflySpawnChance)
		fireflyCount += spawnAtPoint(fireflyScene, middlePoint, fireflySpawnChance)
	print ("Spawned " + str(lanternflyCount) + " Lanternflies" + " and " + str(fireflyCount) + " Fireflies")
