extends LanternflyState
class_name LanternflySearchingForPlayerState

func enter():
	lanternfly.stateLabel.text = "Player"

func update(_delta: float):
	if lanternfly.global_position.distance_to(lanternfly.percievedPlayer.global_position) > lanternfly.percievedPlayer.trackableDistance or not lanternfly.percievedPlayer.isTrackableByEnemy:
		lanternfly.percievedPlayer = null

	if not lanternfly.percievedMotes.is_empty() and lanternfly.scoreLightDesire(lanternfly.getPreferredMote()) > lanternfly.scoreLightDesire(lanternfly.percievedPlayer):
		transition.emit(self, "searchingForMote")
	if not lanternfly.percievedPlayer:
		transition.emit(self, "idle")

func physicsUpdate(_delta: float):
	if lanternfly.percievedPlayer:
		lanternfly.moveToward(lanternfly.percievedPlayer.global_position)
