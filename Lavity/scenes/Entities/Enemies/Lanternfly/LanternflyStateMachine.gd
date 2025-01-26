extends FSM
class_name LanternflyStateMachine

@onready var lanternfly: Lanternfly = get_parent()

func _ready() -> void:
	super._ready()
	for state in get_children():
		if state is LanternflyState:
			states[state.name.to_lower()].lanternfly = lanternfly
