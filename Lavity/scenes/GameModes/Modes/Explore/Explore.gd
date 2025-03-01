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
@onready var activeCoords = []
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
	currentChunk = globalPositionToChunkCoords(player.global_position)
	WorldSave.chunkAdded.connect(spawnCreaturesInChunk)
	loadChunks()

func _process(_delta: float) -> void:
	currentChunk = globalPositionToChunkCoords(player.global_position)
	if previousChunk != currentChunk:
		if !chunkLoaded:
			loadChunks()
	else:
		chunkLoaded = false
	previousChunk = currentChunk

###################### 
# Spawning functions #
######################

var lanternflies: Array[Lanternfly] = []
var fireflies: Array[Firefly] = []
var motes: Array[Mote] = []

func spawnCreaturesInChunk(chunkCoords: Vector2i):
	lanternflies.append_array(GameFlow.spawnAtPoint(lanternflyScene, getRandomPositionInChunk(chunkCoords), lanternflySpawnChance, lanternflySpawnTries))
	fireflies.append_array(GameFlow.spawnAtPoint(fireflyScene, getRandomPositionInChunk(chunkCoords), fireflySpawnChance, fireflySpawnTries))
	motes.append_array(GameFlow.spawnAtPoint(moteScene, getRandomPositionInChunk(chunkCoords), moteSpawnChance, moteSpawnTries, func(mote: Mote): var val = randf_range(1.5, 5.0); mote.lavityLight.light.scale = Vector2(val, val)))

func getRandomPositionInChunk(chunkCoords: Vector2i):
	var x = randf_range(0, chunkSize)
	var y = randf_range(0, chunkSize)
	return Vector2(x, y) + (chunkCoords * chunkSize)

func freeCreaturesInChunk(chunkCoords: Vector2i):
	for lanternfly in lanternflies:
		if !is_instance_valid(lanternfly):
			lanternflies.erase(lanternfly)
			continue
		if globalPositionToChunkCoords(lanternfly.global_position) == chunkCoords:
			SignalBus.lanternflyFreeing.emit(lanternfly)
			lanternflies.erase(lanternfly)
			lanternfly.queue_free()

	for firefly in fireflies:
		if !is_instance_valid(firefly):
			fireflies.erase(firefly)
			continue
		if globalPositionToChunkCoords(firefly.global_position) == chunkCoords:
			SignalBus.fireflyFreeing.emit(firefly)
			fireflies.erase(firefly)
			firefly.queue_free()

	for mote in motes:
		if !is_instance_valid(mote):
			motes.erase(mote)
			continue
		if globalPositionToChunkCoords(mote.global_position) == chunkCoords:
			SignalBus.moteFreeing.emit(mote)
			motes.erase(mote)
			mote.queue_free()
	
###################### 
# Chunking functions #
######################

func globalPositionToChunkCoords(globalPosition: Vector2) -> Vector2i:
	var chunkPos = Vector2i(int(globalPosition.x / chunkSize), int(globalPosition.y / chunkSize))
	if globalPosition.x < 0:
		chunkPos.x -= 1
	if globalPosition.y < 0:
		chunkPos.y -= 1

	return chunkPos

# TODO: Use this function (or fix it) to free the creatures that are outside of the active chunks
func isGlobalPositionOutsideOfActiveChunks(globalPosition: Vector2) -> bool:
	var chunkCoords = globalPositionToChunkCoords(globalPosition)
	return activeCoords.find(chunkCoords) == -1

func loadChunks() -> void:
	var loadedCoords = []

	for x in range(renderBounds):
		for y in range(renderBounds):
			var _x = (x + 1) - round(renderBounds / 2.0) + currentChunk.x
			var _y = (y + 1) - round(renderBounds / 2.0) + currentChunk.y

			var chunkCoords = Vector2(_x, _y)
			var chunkKey = getChunkKey(chunkCoords)
			loadedCoords.append(chunkCoords)

			if activeCoords.find(chunkCoords) == -1:
				var chunk = chunkNodeScene.instantiate()
				chunk.position = chunkCoords * chunkSize
				activeChunks.append(chunk)
				activeCoords.append(chunkCoords)
				chunk.start(chunkKey, chunkSize)
				add_child(chunk)
	var chunkCoordsToDelete = []
	for coord in activeCoords:
		if loadedCoords.find(coord) == -1:
			chunkCoordsToDelete.append(coord)
	for coord in chunkCoordsToDelete:
		var index = activeCoords.find(coord)
		freeCreaturesInChunk(activeCoords[index])
		activeChunks[index].save()
		activeChunks.remove_at(index)
		activeCoords.remove_at(index)
	
	chunkLoaded = true

# this converts the chunks coords to it's key....
# this is for circumanigation 
func getChunkKey(coords: Vector2) -> Vector2:
	var key = coords
	if !circumnavigation:
		return key
	key.x = wrapf(coords.x, -revolution_distance, revolution_distance + 1)
	return key
