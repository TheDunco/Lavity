extends CharacterBody2D
class_name Roamer

@export var acceleration := 10.0
var shouldChaseMouse := true

func chaseMouse():
	var mousePos = get_global_mouse_position()
	var direction = global_position.direction_to(mousePos)
	look_at(mousePos)
	var distanceToMouse = global_position.distance_to(mousePos)
	velocity += direction * (acceleration + distanceToMouse / 100)
	
func randomizeColor():
	$RandColorLight.color = GLOBAL_UTILS.randColor()

func _physics_process(_delta):
	if shouldChaseMouse:
		chaseMouse()
	velocity = $VelocityComponent.handleExistingVelocity(self)
	
func _process(_delta):
	$FlippingSprite.speed_scale = $VelocityComponent.getAnimationSpeed(velocity)
	if Input.is_action_just_pressed("change_color"):
		randomizeColor()

func _on_menu_2d_mouse_light_visible_change(vis):
	shouldChaseMouse = vis
