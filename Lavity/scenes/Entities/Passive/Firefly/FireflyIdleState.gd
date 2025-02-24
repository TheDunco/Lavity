extends FireflyState
class_name FireflyIdleState

func enter():
	if firefly:
		firefly.stateLabel.text = "Idle"
		firefly.flippingSprite.animation = "landed"

func update(_delta: float):
	if not firefly.percievedBodies.is_empty():
		transition.emit(self, "runningFromEntityState")
		return
	if not firefly.percievedFireflies.is_empty():
		transition.emit(self, "followingFireflyState")
		return

func exit():
	if firefly:
		firefly.flippingSprite.animation = "flying"

# func physicsUpdate(_delta: float):
	# firefly.velocity += moveDirection * firefly.acceleration
