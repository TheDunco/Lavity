extends LanternflyState
class_name LanternflySearchingForPlayerState

func enter():
	lanternfly.stateLabel.text = "Searching for player"

func update(_delta: float):

	if lanternfly.global_position.distance_to(lanternfly.percievedPlayer.global_position) > lanternfly.percievedPlayer.trackableDistance:
		lanternfly.percievedPlayer = null

	if not lanternfly.percievedMotes.is_empty():
		transition.emit(self, "searchingForMote")
	elif not lanternfly.percievedPlayer:
		transition.emit(self, "idle")

func physicsUpdate(_delta: float):
	if lanternfly.percievedPlayer:
		lanternfly.moveToward(lanternfly.percievedPlayer.global_position)
