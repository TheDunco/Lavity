extends CharacterBody2D
class_name Firefly

@export var lavityLight: LavityLight = null

@export_category("Timer Config")
@export var impulseTimer: Timer = null
@export var maxRandImpulseSeconds := 2.0
@export_range(100.0, 1000.0) var impulse: float = 500.0
@export var lightTimer: Timer = null
@export var maxRandLightSeconds := 4.0

var lookThreshold := 40.0
@onready var lavityLightLight: PointLight2D = lavityLight.find_child("LavityLightLight", false)

func applyRandomImpulse() -> void:
	velocity += Vector2(randf_range(-impulse, impulse), randf_range(-impulse, impulse))
	look_at(velocity.normalized())
	
func _physics_process(_delta):
	velocity = $VelocityComponent.handleExistingVelocity(self.velocity)
	move_and_slide()
	
func _process(_delta):
	#$FlippingSprite.speed_scale = $VelocityComponent.getAnimationSpeed(self.velocity)

	# Look towards the direction of travel
	if abs(velocity.x) > lookThreshold or abs(velocity.y) > lookThreshold:
		look_at(velocity.normalized() + position)

func _on_impulse_timer_timeout():
	applyRandomImpulse()
	impulseTimer.wait_time = randf_range(0.5, maxRandImpulseSeconds)
	impulseTimer.paused = false
	impulseTimer.start()

func _on_light_timer_timeout():
	if lavityLight.process_mode == Node.PROCESS_MODE_DISABLED:
		lavityLight.process_mode = Node.PROCESS_MODE_INHERIT
		lavityLightLight.enabled = true
	else:
		lavityLight.process_mode = Node.PROCESS_MODE_DISABLED
		lavityLightLight.enabled = false
		
		
	lightTimer.wait_time = randf_range(0.5, maxRandLightSeconds)
	lightTimer.paused = false
	lightTimer.start()
