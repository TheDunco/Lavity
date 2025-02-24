extends FireflyState
class_name FireflyFollowingFireflyState

var followFirefly: Firefly = null

func enter() -> void:
	if firefly:
		followFirefly = firefly.percievedFireflies.pick_random()
		print_debug("entering following firefly state")
		if not firefly.percievedBodies.is_empty():
			transition.emit(self, "runningFromEntityState")
		elif not firefly.percievedFireflies.is_empty():
			firefly.blinkTime = followFirefly.blinkTime
		else:
			transition.emit(self, "idleState")

func update(_delta) -> void:
	if not firefly.percievedBodies.is_empty():
		transition.emit(self, "runningFromEntityState")
		return

	firefly.moveToward(followFirefly.global_position)

func exit() -> void:
	if firefly:
		firefly.blinkTime = firefly.initialBlinkTime
	followFirefly = null
