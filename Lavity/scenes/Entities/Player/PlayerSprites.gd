extends AnimatedSprite2D

@export var legs: Array[Sprite2D]
@export var antenna: Sprite2D
@onready var velocityComponent: VelocityComponent = $"../VelocityComponent"
@onready var flipping_sprite: AnimatedSprite2D = $"."
@onready var player: Player = get_parent()

const VELOCITY_SUM_CUTOFF := 7

func _ready():
	play()

func _process(_delta: float) -> void:
	var velocity = player.velocity
	var velocitySum = abs(velocity.x) + abs(velocity.y)
	if velocitySum < VELOCITY_SUM_CUTOFF:
		return

	var legRotation := remap(velocitySum, 0, velocityComponent.maxVelocity, 0, 40)
	var antennaRotation := remap(velocitySum, 0, velocityComponent.maxVelocity, 0, 30)

	if legRotation > 20.0:
		legRotation += randf_range(-2.5, 2.5)

	for leg in legs:
		leg.rotation_degrees = legRotation + randf_range(-2.5, 2.5)
		
	antenna.rotation_degrees = -antennaRotation
