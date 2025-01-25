extends Node
class_name State

# Many thanks to https://youtu.be/ow_Lum-Agbs?si=j-hNRRlvRreOMqne for the helpful video of implementing a FSM in Godot

signal transition(state: State, newStateName: String)

func enter():
	pass

func exit():
	pass

func update(_delta: float):
	pass

func physicsUpdate(_delta: float):
	pass
