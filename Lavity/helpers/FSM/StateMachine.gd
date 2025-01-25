extends Node
class_name FSM

@export var initialState: State

var states: Dictionary = {}
var currentState: State

func _ready():
	for state in get_children():
		if state is State:
			states[state.name.to_lower()] = state
			state.transition.connect(onStateTransition)
	if initialState:
		initialState.enter()
		currentState = initialState

func _process(delta: float) -> void:
	if currentState:
		currentState.update(delta)

func _physics_process(delta: float) -> void:
	if currentState:
		currentState.physicsUpdate(delta)

func onStateTransition(state: State, newStateName: String) -> void:
	if state != currentState:
		return

	var newState = states.get(newStateName.to_lower())
	if !newState:
		return

	if currentState:
		currentState.exit()
	
	newState.enter()
	currentState = newState
