extends Node2D

const CHUNK_SIZE = 10000

@onready var player: Player = $Player
@onready var background: Sprite2D = $WhiteBackground

func _ready() -> void:
	SignalBus.displayHeroText.emit("")

func _process(_delta: float) -> void:
	background.global_position = player.global_position
