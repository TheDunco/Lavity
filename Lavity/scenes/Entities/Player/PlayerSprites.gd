extends AnimatedSprite2D

@export var legs: Array[Sprite2D]
@export var antenna: Sprite2D

func _ready():
	play()

func _process(_delta: float) -> void:
	var velocity = $"..".velocity
	var velocitySum = abs(velocity.x) + abs(velocity.y)
	if velocitySum < 7:
		return
	var legRotation := remap(velocitySum, 0, $"../VelocityComponent".maxVelocity/2, 0, 40)
	var antennaRotation := remap(velocitySum, 0, $"../VelocityComponent".maxVelocity/2, 0, 30)
	
	if legRotation > 20.0:
		legRotation += randf_range(-2.5, 2.5)

	for leg in legs:
		leg.rotation_degrees = legRotation + randf_range(-2.5, 2.5)
		
	antenna.rotation_degrees = -antennaRotation
