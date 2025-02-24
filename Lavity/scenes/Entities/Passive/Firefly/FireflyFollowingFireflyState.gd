extends FireflyState
class_name FireflyFollowingFireflyState

var followFirefly: Firefly = null
var storedInitialBlinkTime: float

func enter() -> void:
	if firefly:
		followFirefly = firefly.percievedFireflies.pick_random()
		print_debug("entering following firefly state")
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

	if firefly.global_position.distance_to(followFirefly.global_position) > 300:
		firefly.moveToward(followFirefly.global_position, firefly.acceleration / 2)

func exit() -> void:
	if firefly:
		firefly.initialBlinkTime = storedInitialBlinkTime
		firefly.resetBlinkTime(storedInitialBlinkTime)
	followFirefly = null
