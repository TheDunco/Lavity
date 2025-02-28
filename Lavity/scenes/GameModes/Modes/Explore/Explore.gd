extends Node2D

@export var chunkSize := 5000.0
@export var renderDistance := 2
# revolution distance is the distance at which the player must move on the axis in chunk coords
# in order for one revolution to be achived.
@export var circumnavigation := false
@export var revolution_distance := 8

@export_range(0, 20) var lanternflySpawnTries = 1
@export_range(0.0, 1.0) var lanternflySpawnChance
@export_range(0, 20) var fireflySpawnTries = 1
@export_range(0.0, 1.0) var fireflySpawnChance
@export_range(0, 20) var moteSpawnTries = 1
@export_range(0.0, 1.0) var moteSpawnChance

@onready var renderBounds = (float(renderDistance) * 2.0) + 1.0
@onready var player: Player = $Player
@onready var activeCoord = []
@onready var activeChunks = []

var currentChunk: Vector2i
var previousChunk: Vector2i

var chunkLoaded = false
var visitedChunks = []

const chunkNodeScene = preload("res://scenes/Utils/ChunkLoading/ChunkNode.tscn")
const lanternflyScene = preload("res://scenes/Entities/Enemies/Lanternfly/Lanternfly.tscn")
const fireflyScene = preload("res://scenes/Entities/Passive/Firefly/Firefly.tscn")
const moteScene = preload("res://scenes/Objects/Mote.tscn")

func _ready() -> void:
	SignalBus.displayHeroText.emit("")
	currentChunk = playerPosToChunkCoords(player.global_position)
	WorldSave.chunkAdded.connect(spawnCreaturesInChunk)
	loadChunk()

func _process(_delta: float) -> void:
	currentChunk = playerPosToChunkCoords(player.global_position)
	if previousChunk != currentChunk:
		if !chunkLoaded:
			loadChunk()
	else:
		chunkLoaded = false
	previousChunk = currentChunk

###################### 
# Spawning functions #
######################

func spawnCreaturesInChunk(chunkCoords: Vector2i):
	GameFlow.spawnAtPoint(lanternflyScene, getRandomPositionInChunk(chunkCoords), lanternflySpawnChance, lanternflySpawnTries)
	GameFlow.spawnAtPoint(fireflyScene, getRandomPositionInChunk(chunkCoords), fireflySpawnChance, fireflySpawnTries)
	GameFlow.spawnAtPoint(moteScene, getRandomPositionInChunk(chunkCoords), moteSpawnChance, moteSpawnTries, func(mote: Mote): var val = randf_range(1.5, 5.0); mote.lavityLight.light.scale = Vector2(val, val))

func getRandomPositionInChunk(chunkCoords: Vector2i):
	var x = randf_range(0, chunkSize)
	var y = randf_range(0, chunkSize)
	return Vector2(x, y) + (chunkCoords * chunkSize)
	
###################### 
# Chunking functions #
######################

func playerPosToChunkCoords(pos: Vector2) -> Vector2i:
	var chunkPos = Vector2i(int(pos.x / chunkSize), int(pos.y / chunkSize))
	if pos.x < 0:
		chunkPos.x -= 1
	if pos.y < 0:
		chunkPos.y -= 1

	return chunkPos

func loadChunk() -> void:
	var loadedCoords = []

	for x in range(renderBounds):
		for y in range(renderBounds):
			var _x = (x + 1) - round(renderBounds / 2.0) + currentChunk.x
			var _y = (y + 1) - round(renderBounds / 2.0) + currentChunk.y

			var chunkCoords = Vector2(_x, _y)
			var chunkKey = getChunkKey(chunkCoords)
			loadedCoords.append(chunkCoords)

			if activeCoord.find(chunkCoords) == -1:
				var chunk = chunkNodeScene.instantiate()
				chunk.position = chunkCoords * chunkSize
				activeChunks.append(chunk)
				activeCoord.append(chunkCoords)
				chunk.start(chunkKey, chunkSize)
				add_child(chunk)
	var deletingChunks = []
	for x in activeCoord:
		if loadedCoords.find(x) == -1:
			deletingChunks.append(x)
	for x in deletingChunks:
		var index = activeCoord.find(x)
		activeChunks[index].save()
		activeChunks.remove_at(index)
		activeCoord.remove_at(index)
	
	chunkLoaded = true

# this converts the chunks coords to it's key....
# this is for circumanigation 
func getChunkKey(coords: Vector2) -> Vector2:
	var key = coords
	if !circumnavigation:
		return key
	key.x = wrapf(coords.x, -revolution_distance, revolution_distance + 1)
	return key
