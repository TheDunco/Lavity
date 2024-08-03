extends Camera2D

const MAX_SMOOTHING_DISTANCE := 10

@export_category("Follow Character")
@export var player: CharacterBody2D

@export_category("Camera Smoothing")
@export var smoothingEnabled: bool
@export_range(1, MAX_SMOOTHING_DISTANCE) var smoothingDistance := 2

var weight: float

func calcWeight():
	return  float((MAX_SMOOTHING_DISTANCE + 1) - smoothingDistance) / 100

func _ready():
	weight = calcWeight()

#func _physics_process(delta):
	#pass
	#if player != null:
		#var cameraPosition: Vector2
		#
		#if smoothingEnabled:
			#cameraPosition = lerp(global_position, player.global_position, weight)
		#else:
			#cameraPosition = player.global_position
	#
		#global_position = cameraPosition.floor()
		#
		#global_position = player.global_position
	
	
