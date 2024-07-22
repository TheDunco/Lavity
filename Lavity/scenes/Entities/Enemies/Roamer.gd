extends CharacterBody2D
class_name Roamer

@export var acceleration := 10

func _physics_process(delta):
	var mousePos = get_global_mouse_position()
	var direction = global_position.direction_to(mousePos)
	look_at(mousePos)
	velocity += direction * acceleration
	$VelocityComponent.handleExistingVelocity(self)
	
func _process(_delta):
	$FlippingSprite.speed_scale = $VelocityComponent.getAnimationSpeed(velocity)
