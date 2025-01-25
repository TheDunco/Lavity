extends State
class_name LanternflySearchingForMoteState

@export var lanternfly: Lanternfly
var preferredMote: Mote = null

func setPreferredMote():
	for mote in lanternfly.percievedMotes:
		if lanternfly.scoreMote(mote) > lanternfly.scoreMote(preferredMote):
			preferredMote = mote

func enter():
	SignalBus.emit_signal("displayHeroText", "[wave]Lanternfly:[/wave] Searching for mote")
	lanternfly.stateLabel.text = "Searching for mote"
	setPreferredMote()

func update(_delta: float):
	if lanternfly.percievedMotes.is_empty():
		if lanternfly.percievedPlayer:
			transition.emit(self, "searchingForPlayer")
		else:
			transition.emit(self, "idle")

func physicsUpdate(_delta: float):
	if preferredMote:
		lanternfly.moveToward(preferredMote.rigidBody.global_position)
