extends FSM
class_name LanternflyStateMachine

# State priority
# The Lanternfly will prioritize motes over the player if it sees both
# This is because, evolutionarily, it would prioritize the low hanging fruit vs something that will fight back or run away
# It also makes the player have to fight for the motes with the Lanternflies as well as fight them which is fun

@onready var lanternfly: Lanternfly = get_parent()

func _ready() -> void:
	super._ready()
	for state in get_children():
		if state is LanternflyState:
			states[state.name.to_lower()].lanternfly = lanternfly
