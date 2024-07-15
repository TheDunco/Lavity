extends Node2D
class_name Enemy

func _ready():
	$CharacterBody2D/EnemySpriteAnimated.play()
