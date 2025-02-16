extends RepulsableBody
class_name Firefly

# TODO: Make fireflies tend to group together and sync up their blinks!
# Perhaps with a FireflyCommunicatingWithFirefly state or the like

@export var acceleration := 16
@export var healRate := 0.00015

@onready var stateLabel: Label = $StateLabel
@onready var velocityComponent: VelocityComponent = $VelocityComponent
@onready var perceptionArea: Area2D = $PerceptionArea
@onready var lavityLight: LavityLight = $LavityLight
@onready var targetColor := ColorUtils.randColorFromSet()
@onready var particles: CPUParticles2D = $CPUParticles2D

var percievedBodies: Array[CharacterBody2D] = []
var _prevPosition := global_position

var distanceMoved: float = 0

func bodyEnteredPerceptionArea(body: Node):
	if body is CharacterBody2D and body != self:
		percievedBodies.append(body)

func bodyExitedPerceptionArea(body: Node):
	if body is CharacterBody2D:
		percievedBodies.erase(body)

func _ready() -> void:
	super._ready()
	perceptionArea.connect("body_entered", bodyEnteredPerceptionArea)
	perceptionArea.connect("body_exited", bodyExitedPerceptionArea)
	SignalBus.connect("lanternflyFreeing", func(fly): percievedBodies.erase(fly))
	lavityLight.light.color = targetColor
	particles.color = targetColor
	particles.color.a = GlobalConfig.ENTITY_PARTICLES_ALPHA
	
func _physics_process(_delta):
	_prevPosition = global_position
	velocity = velocityComponent.handleExistingVelocity(self.velocity)
	look_at(velocity.normalized() + position)
	move_and_slide()
	distanceMoved = _prevPosition.distance_to(global_position)
	
var lightVisibleTime := 2.0

func _process(delta):
	if lightVisibleTime > 0:
		lightVisibleTime -= delta
	else:
		lavityLight.light.visible = !lavityLight.light.visible
		particles.emitting = !particles.emitting
		lightVisibleTime = 2.0
		# This is more or less what I want to replace the above but it isn't working as expected because it's repelling from the player at 0% when it should be at 50% (equal/opposite)
		# match lavityLight.process_mode:
		# 	PROCESS_MODE_DISABLED:
		# 		lavityLight.process_mode = PROCESS_MODE_INHERIT
		# 		lavityLight.light.enabled = true
		# 	PROCESS_MODE_INHERIT:
		# 		lavityLight.process_mode = PROCESS_MODE_DISABLED
		# 		lavityLight.light.enabled = false

	
	var blackLikeness = ColorUtils.scoreColorLikeness(lavityLight.light.color, Color.BLACK)
	if blackLikeness > 0.80 and lavityLight.light.visible:
		SignalBus.emit_signal("fireflyFreeing", self)
		queue_free()
	if ColorUtils.scoreColorLikeness(lavityLight.light.color, targetColor) < 0.9:
		lavityLight.light.color = ColorUtils.healTowardsTarget(lavityLight.light.color, targetColor, healRate)
