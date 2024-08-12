extends AnimatedSprite2D

@export var legs: Array[Sprite2D]
@export var antenna: Sprite2D

func _ready():
	play()

func _process(_delta: float) -> void:
	var velocity = $"..".velocity
	var velocitySum = abs(velocity.x) + abs(velocity.y)
	var rotation := remap(velocitySum, 0, $"../VelocityComponent".maxVelocity/2, 0, 40)
	
	if rotation > 20.0:
		rotation += randf_range(-10.0, 10.0)

	for leg in legs:
		leg.rotation_degrees = rotation + randf_range(-5.0, 5.0)
		
	antenna.rotation_degrees = -rotation
