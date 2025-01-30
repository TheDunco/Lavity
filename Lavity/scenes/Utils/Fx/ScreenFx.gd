extends Node2D

@onready var repulseAnimation: AnimationPlayer = $FxCanvasLayer/RepulseAnimation

func playAnimation(_playerGlobalPosition):
	repulseAnimation.play("Repulse")

func _ready() -> void:
	SignalBus.connect("playerRepulsed", playAnimation)
