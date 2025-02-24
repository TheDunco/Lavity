extends FireflyState
class_name FireflyFollowingFireflyState

var followFirefly: Firefly = null
var storedInitialBlinkTime: float

@export var mateMoteSpawnChance := 0.1
@export var mateFireflySpawnChance := 0.05

@onready var moteScene = preload("res://scenes/Objects/Mote.tscn")
@onready var fireflyScene = preload("res://scenes/Entities/Passive/Firefly/Firefly.tscn")

@onready var root := get_tree().root

func getBlendedColor() -> Color:
	if is_instance_valid(self) and is_instance_valid(followFirefly):
		return firefly.lavityLight.light.color.lerp(followFirefly.lavityLight.light.color, 1.0)
	return Color.BLACK

func trySpawn():
	var adults = not firefly.isChild and not followFirefly.isChild
	var differentSex = firefly.isFemale == not followFirefly.isFemale
	var notOverpopulated = firefly.percievedFireflies.size() < 5

	var shouldSpawnMote: bool = (randf() < mateMoteSpawnChance) \
		and notOverpopulated and adults and differentSex

	var shouldSpawnFirefly: bool = (randf() < mateFireflySpawnChance) \
		and notOverpopulated and adults and differentSex

	if shouldSpawnMote:
		var distractingMote = moteScene.instantiate()
		distractingMote.global_position = firefly.global_position
		root.add_child(distractingMote)
		distractingMote.decayRate = 0.02
		distractingMote.changeColor(getBlendedColor())
		distractingMote.pop.play()
	elif shouldSpawnFirefly:
		var spawnFirefly = fireflyScene.instantiate()
		spawnFirefly.global_position = firefly.global_position
		root.add_child(spawnFirefly)
		spawnFirefly.lavityLight.light.color = getBlendedColor()
		spawnFirefly.scale = Vector2.ONE / 2.0
		spawnFirefly.initialBlinkTime = firefly.initialBlinkTime
		spawnFirefly.isChild = true
		spawnFirefly.blinksToGrowUp = firefly.blinksToGrowUp + followFirefly.blinksToGrowUp
		

func enter() -> void:
	if firefly:
		followFirefly = firefly.percievedFireflies.pick_random()
		followFirefly.blink.connect(trySpawn)
		if not firefly.percievedBodies.is_empty():
			transition.emit(self, "runningFromEntityState")
		elif not firefly.percievedFireflies.is_empty():
			storedInitialBlinkTime = firefly.initialBlinkTime
			firefly.initialBlinkTime = followFirefly.initialBlinkTime
			firefly.resetBlinkTime(followFirefly.initialBlinkTime)
			followFirefly.resetBlinkTime()
		else:
			transition.emit(self, "idleState")

func update(_delta) -> void:
	if not firefly.percievedBodies.is_empty():
		transition.emit(self, "runningFromEntityState")
		return

	if firefly.global_position.distance_to(followFirefly.global_position) > 250:
		firefly.moveToward(followFirefly.global_position, firefly.acceleration / 100.0)

func exit() -> void:
	if firefly:
		firefly.initialBlinkTime = storedInitialBlinkTime
		firefly.resetBlinkTime(storedInitialBlinkTime)
	
	followFirefly.blink.disconnect(trySpawn)
	followFirefly = null
