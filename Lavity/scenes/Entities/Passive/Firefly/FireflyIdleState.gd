extends FireflyState
class_name FireflyIdleState

var moveDirection: Vector2 = Vector2.ZERO
var wanderTime: float = 0.0

func randomizeWander():
	wanderTime = randf_range(0.3, 1.0)
	if firefly.distanceMoved <= 1 and moveDirection != Vector2.ZERO:
		moveDirection = -moveDirection
	else: 
		moveDirection = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func enter():
	if firefly:
		randomizeWander()
		firefly.stateLabel.text = "Idle"

func update(delta: float):
	if not firefly.percievedBodies.is_empty():
		transition.emit(self, "runningFromEntityState")
		return

	if wanderTime > 0:
		wanderTime -= delta
	else:
		randomizeWander()

func physicsUpdate(_delta: float):
	firefly.velocity += moveDirection * firefly.acceleration
