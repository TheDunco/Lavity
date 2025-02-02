extends FSM
class_name FireflyStateMachine

@onready var firefly: Firefly = get_parent()

func _ready() -> void:
	super._ready()
	for state in get_children():
		if state is FireflyState:
			states[state.name.to_lower()].firefly = firefly
