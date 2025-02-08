extends Node
class_name State

# Many thanks to https://youtu.be/ow_Lum-Agbs?si=j-hNRRlvRreOMqne for the helpful video of implementing a FSM in Godot

signal transition(state: State, newStateName: String)

## Will be called on the leading edge when the state is entered
func enter():
	pass

## Will be called when the state is exited
func exit():
	pass

## Will be called for each CPU update (_process) cycle
func update(_delta: float):
	pass

## Will be called for each GPU update (_physics_process) cycle
func physicsUpdate(_delta: float):
	pass
