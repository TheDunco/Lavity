extends Node2D

var lanternflyScene = preload("res://scenes/Entities/Enemies/Lanternfly/Lanternfly.tscn")

@onready var maze: ProceduralMaze = get_parent()
@export var lanternflySpawnChance := 0.1

func _ready() -> void:
	var mazeMiddlePoints: Array[Vector2] = maze.getTileCenters()
	var lanternflyCount = 0

	for middlePoint in mazeMiddlePoints:
		if randf() < lanternflySpawnChance:
			var lanternflyInstance = lanternflyScene.instantiate()
			lanternflyInstance.global_position = middlePoint
			add_child(lanternflyInstance)
			lanternflyCount += 1
	print ("Spawned " + str(lanternflyCount) + " Lanternflies")
