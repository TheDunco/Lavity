extends Node2D

@export var sounds: Array[AudioStreamPlayer2D]
@export var spriteFrameToPlaySound := 0

@onready var sprite: AnimatedSprite2D = get_parent()

func _process(_delta: float) -> void:
	if sprite.frame == spriteFrameToPlaySound:
		var sound: AudioStreamPlayer2D = sounds.pick_random()
		sound.pitch_scale = randf_range(0.5, 1.2)
		sound.play()
		
