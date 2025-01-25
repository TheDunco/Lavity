extends State
class_name LanternflySearchingForMoteState

@export var lanternfly: Lanternfly
@export var maxStuckTime: float = 5.0
var timeStuck := 0.0

func getPreferredMote() -> Mote:
	var ret = null
	for mote in lanternfly.percievedMotes:
		if lanternfly.scoreMote(mote) > lanternfly.scoreMote(ret):
			ret = mote
	return ret


func enter():
	SignalBus.emit_signal("displayHeroText", "[wave]Lanternfly:[/wave] Searching for mote")
	lanternfly.stateLabel.text = "Searching for mote"

func exit():
	timeStuck = 0.0

func update(delta: float):
	if lanternfly.percievedMotes.is_empty():
		transition.emit(self, "idle")
		return

	if timeStuck > maxStuckTime:
		lanternfly.percievedMotes.erase(getPreferredMote())
		transition.emit(self, "idle")
		return

	if lanternfly.velocity.x + lanternfly.velocity.y < 5:
		timeStuck += delta
	else:
		timeStuck = 0.0

func physicsUpdate(_delta: float):
	var preferredMote = getPreferredMote()
	if preferredMote:
		lanternfly.moveToward(preferredMote.rigidBody.global_position)
