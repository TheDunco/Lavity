extends State
class_name LanternflySearchingForPlayerState

@export var lanternfly: Lanternfly

func enter():
	SignalBus.emit_signal("displayHeroText", "[wave]Lanternfly:[/wave] Searching for player")
	lanternfly.stateLabel.text = "Searching for player"

func update(_delta: float):
	if lanternfly.percievedMotes.size() > 0:
		transition.emit(self, "searchingForMote")
	elif !lanternfly.percievedPlayer:
		transition.emit(self, "idle")

func physicsUpdate(_delta: float):
	if lanternfly.percievedPlayer:
		lanternfly.moveToward(lanternfly.percievedPlayer.global_position)
