extends CharacterBody2D
class_name Firefly

@export var impulseTimer: Timer = null
@export var lightTimer: Timer = null
@export_range(100.0, 1000.0) var impulse: float = 500.0
@export var lookThreshold := 50.0

@export var lavityLight: LavityLight = null
var lavityLightLight: PointLight2D = null

func applyRandomImpulse() -> void:
	velocity += Vector2(randf_range(-impulse, impulse), randf_range(-impulse, impulse))
	look_at(velocity.normalized())
	
func _ready() -> void:
	lavityLightLight = lavityLight.find_child("LavityLightLight", false)

func _physics_process(_delta):
	velocity = $VelocityComponent.handleExistingVelocity(self.velocity)
	move_and_slide()
	
func _process(_delta):
	$FlippingSprite.speed_scale = $VelocityComponent.getAnimationSpeed(velocity)

	# Look towards the direction of travel
	if abs(velocity.x) > lookThreshold or abs(velocity.y) > lookThreshold:
		look_at(velocity.normalized() + position)

func _on_impulse_timer_timeout():
	applyRandomImpulse()
	impulseTimer.wait_time = randf_range(0.5, 5.0)
	impulseTimer.paused = false
	impulseTimer.start()

func _on_light_timer_timeout():
	if lavityLight.process_mode == Node.PROCESS_MODE_DISABLED:
		lavityLight.process_mode = Node.PROCESS_MODE_INHERIT
		lavityLightLight.enabled = true
	else:
		lavityLight.process_mode = Node.PROCESS_MODE_DISABLED
		lavityLightLight.enabled = false
		
		
	lightTimer.wait_time = randf_range(0.5, 5.0)
	lightTimer.paused = false
	lightTimer.start()
