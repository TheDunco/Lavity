extends FireflyState
class_name FireflyRunningFromEntityState

var closestBody: CharacterBody2D

func moveAwayFromClosestBody():
	if closestBody and not closestBody.is_queued_for_deletion():
		var direction = -firefly.global_position.direction_to(closestBody.global_position)
		firefly.velocity += direction * firefly.acceleration

func enter():
	firefly.stateLabel.text = "Running"

func update(_delta):
	if firefly.percievedBodies.is_empty():
		transition.emit(self, "idleState")
		return

	closestBody = firefly.percievedBodies[0]
	for body in firefly.percievedBodies:
		if firefly.global_position.distance_to(body.global_position) < firefly.global_position.distance_to(closestBody.global_position):
			closestBody = body
	
func physicsUpdate(_delta):
	moveAwayFromClosestBody()
