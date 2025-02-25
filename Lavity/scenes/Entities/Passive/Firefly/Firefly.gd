extends RepulsableBody
class_name Firefly

# TODO: Make fireflies tend to group together and sync up their blinks!
# Perhaps with a FireflyCommunicatingWithFirefly state or the like

@export var healRate := 0.00015
@export var blinkTime := randf_range(0.5, 3.0)
@export var blinksToGrowUp := 10.0
@export var isFemale := randf() >= 0.5

@onready var initialBlinkTime := blinkTime
@onready var stateLabel: Label = $StateLabel
@onready var velocityComponent: VelocityComponent = $VelocityComponent
@onready var flippingSprite: AnimatedSprite2D = $FlippingSprite
@onready var perceptionArea: Area2D = $PerceptionArea
@onready var lavityLight: LavityLight = $LavityLight
@onready var targetColor := ColorUtils.randColorFromSet()
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var pop = $Pop

var isChild := false
var childBlinkCount := 0.0

signal blink

var percievedBodies: Array[CharacterBody2D] = []
var percievedFireflies: Array[Firefly] = []

func bodyEnteredPerceptionArea(body: Node):
	if body is CharacterBody2D and body != self:
		if body is Firefly:
			print("adding firefly")
			percievedFireflies.append(body)
		else:
			print("adding body")
			percievedBodies.append(body)

func bodyExitedPerceptionArea(body: Node):
	if body is CharacterBody2D:
		if body is Firefly:
			print("removing firefly")
			percievedFireflies.erase(body)
		else:
			print("removing body")
			percievedBodies.erase(body)

func _ready() -> void:
	super._ready()
	flippingSprite.play()
	perceptionArea.body_entered.connect(bodyEnteredPerceptionArea)
	perceptionArea.body_exited.connect(bodyExitedPerceptionArea)
	# SignalBus.lanternflyFreeing.connect(func(fly): percievedBodies.erase(fly))
	# SignalBus.fireflyFreeing.connect(func(firefly): percievedFireflies.erase(firefly))
	lavityLight.light.color = targetColor
	particles.color = targetColor
	particles.color.a = GlobalConfig.ENTITY_PARTICLES_ALPHA
	
func _physics_process(delta):
	velocity = velocityComponent.handleExistingVelocity(self.velocity)
	look_at(velocity.normalized() + position)
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		var direction = collision_info.get_position().direction_to(global_position)
		velocity += direction * GlobalConfig.LAVITY * bounceMult
	
func resetBlinkTime(time: float = initialBlinkTime):
	blinkTime = time
	blink.emit()
	if isChild:
		childBlinkCount += 1.0
		var grownUpRatio = childBlinkCount / blinksToGrowUp
		scale = scale.lerp(Vector2(grownUpRatio, grownUpRatio), 1.0)
	if childBlinkCount > blinksToGrowUp:
		scale = Vector2.ONE
		isChild = false

func _process(delta):
	flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(self.velocity)
	if blinkTime > 0:
		blinkTime -= delta
	else:
		lavityLight.light.visible = !lavityLight.light.visible
		particles.emitting = !particles.emitting
		resetBlinkTime()
		# # This is more or less what I want to replace the above but it isn't working as expected because it's repelling from the player at 0% when it should be at 50% (equal/opposite)
		match lavityLight.process_mode:
			PROCESS_MODE_DISABLED:
				lavityLight.process_mode = PROCESS_MODE_INHERIT
				lavityLight.light.enabled = true
			PROCESS_MODE_INHERIT:
				lavityLight.process_mode = PROCESS_MODE_DISABLED
				lavityLight.light.enabled = false

	
	var blackLikeness = ColorUtils.scoreColorLikeness(lavityLight.light.color, Color.BLACK)
	if blackLikeness > 0.80 and lavityLight.light.visible:
		SignalBus.emit_signal("fireflyFreeing", self)
		queue_free()
	if ColorUtils.scoreColorLikeness(lavityLight.light.color, targetColor) < 0.9:
		lavityLight.light.color = ColorUtils.healTowardsTarget(lavityLight.light.color, targetColor, healRate)
