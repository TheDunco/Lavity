extends LanternflyState
class_name LanternflyIdleState

var moveDirection: Vector2 = Vector2.ZERO
var wanderTime: float = 0.0

func randomizeWander():
	moveDirection = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wanderTime = randf_range(1, 3)

func enter():
	SignalBus.emit_signal("displayHeroText", "[wave]Lanternfly:[/wave] Idle")
	randomizeWander()

func update(delta: float):
	if lanternfly.percievedMotes.size() > 0:
		transition.emit(self, "searchingForMote")
	elif lanternfly.percievedPlayer:
		transition.emit(self, "searchingForPlayer")

	if wanderTime > 0:
		wanderTime -= delta
	else:
		randomizeWander()

func physicsUpdate(_delta: float):
	lanternfly.look_at(lanternfly.global_position + moveDirection)
	lanternfly.velocity += moveDirection * lanternfly.acceleration
