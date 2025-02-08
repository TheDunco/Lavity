extends LanternflyState
class_name LanternflyIdleState

var moveDirection: Vector2 = Vector2.ZERO
var wanderTime: float = 0.0

# TODO: Make this slightly less random: make it go to the inverse normal of the wall with a little variation so it bounces around more instead of getting stuck so often
func randomizeWander():
	moveDirection = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wanderTime = randf_range(2, 3)

func enter():
	randomizeWander()
	if lanternfly:
		lanternfly.stateLabel.text = "Idle"

func update(delta: float):
	if lanternfly.percievedMotes.size() > 0:
		transition.emit(self, "searchingForMote")
	elif lanternfly.percievedPlayer:
		transition.emit(self, "searchingForPlayer")
	elif not lanternfly.percievedFireflies.is_empty():
		transition.emit(self, "searchingForFirefly")

	if wanderTime > 0:
		wanderTime -= delta
	else:
		randomizeWander()

func physicsUpdate(_delta: float):
	lanternfly.velocity += moveDirection * lanternfly.acceleration
