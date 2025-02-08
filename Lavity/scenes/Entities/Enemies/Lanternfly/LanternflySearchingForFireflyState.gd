extends LanternflyState
class_name LanternflySearchingForFireflyState

func enter():
	lanternfly.stateLabel.text = "Firefly"

func transitionToPlayer() -> bool:
	if lanternfly.percievedFireflies.is_empty() and lanternfly.percievedPlayer:
		transition.emit(self, "searchingForPlayer")
		return true
	return false

func transitionToMote() -> bool:
	if lanternfly.percievedFireflies.is_empty() and not lanternfly.percievedMotes.is_empty():
		transition.emit(self, "searchingForMote")
		return true
	return false

func transitionToIdle() -> bool:
	if lanternfly.percievedFireflies.is_empty():
		transition.emit(self, "idle")
		return true
	return false

func update(_delta: float):
	if transitionToPlayer():
		return
	elif transitionToMote():
		return
	elif transitionToIdle():
		return

func physicsUpdate(_delta: float):
	var preferredFirefly = lanternfly.getPreferredFirefly()
	if preferredFirefly:
		lanternfly.moveToward(preferredFirefly.global_position)
