extends LanternflyState
class_name LanternflySearchingForMoteState

@export var maxStuckTime: float = 5.0
var timeStuck := 0.0

func enter():
	lanternfly.stateLabel.text = "Searching for mote"

func exit():
	timeStuck = 0.0

func transitionToIdle() -> bool:
	if lanternfly.percievedMotes.is_empty():
		transition.emit(self, "idle")
		return true
	return false

# Only transition to the player if the player's light color is more desireable than the most preferred mote
func transitionToPlayer(preferredMote: Mote) -> bool:
	if lanternfly.percievedPlayer:
		if lanternfly.scoreLightDesire(lanternfly.percievedPlayer) > lanternfly.scoreLightDesire(preferredMote):
			transition.emit(self, "searchingForPlayer")
			return true
	return false

func update(delta: float):
	if transitionToIdle():
		return

	var preferredMote = lanternfly.getPreferredMote()
	if transitionToPlayer(preferredMote):
		return

	if timeStuck > maxStuckTime:
		# If we can't get at the mote, we should forget about it and move on
		if preferredMote:
			lanternfly.percievedMotes.erase(preferredMote)
		transition.emit(self, "idle")
		return

	if lanternfly.velocity.x + lanternfly.velocity.y < 5:
		timeStuck += delta
	else:
		timeStuck = 0.0

func physicsUpdate(_delta: float):
	var preferredMote = lanternfly.getPreferredMote()
	if preferredMote:
		lanternfly.moveToward(preferredMote.rigidBody.global_position)
