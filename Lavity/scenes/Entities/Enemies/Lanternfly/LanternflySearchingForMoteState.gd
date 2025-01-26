extends LanternflyState
class_name LanternflySearchingForMoteState

@export var maxStuckTime: float = 5.0
var timeStuck := 0.0

func getPreferredMote() -> Mote:
	var ret = null
	for mote in lanternfly.percievedMotes:
		if lanternfly.scoreMote(mote) > lanternfly.scoreMote(ret):
			ret = mote
	if ret == null and not shouldTransition():
		return lanternfly.percievedMotes[0]
	return ret


func enter():
	SignalBus.emit_signal("displayHeroText", "[wave]Lanternfly:[/wave] Searching for mote")
	lanternfly.stateLabel.text = "Searching for mote"

func exit():
	timeStuck = 0.0

func shouldTransition() -> bool:
	if lanternfly.percievedMotes.is_empty():
		transition.emit(self, "idle")
		return true
	return false

func update(delta: float):
	if shouldTransition():
		return

	if timeStuck > maxStuckTime:
		var preferredMote = getPreferredMote()
		if preferredMote:
			lanternfly.percievedMotes.erase(getPreferredMote())
		transition.emit(self, "idle")
		return

	if lanternfly.velocity.x + lanternfly.velocity.y < 5:
		timeStuck += delta
	else:
		timeStuck = 0.0

func physicsUpdate(_delta: float):
	var preferredMote = getPreferredMote()
	print_debug(preferredMote)
	if preferredMote:
		lanternfly.moveToward(preferredMote.rigidBody.global_position)
