extends RepulsableBody
class_name Firefly

@export var acceleration := 16

@onready var stateLabel: Label = $StateLabel
@onready var velocityComponent = $VelocityComponent
@onready var perceptionArea: Area2D = $PerceptionArea
@onready var lavityLight: LavityLight = $LavityLight
@onready var targetColor := ColorUtils.randColorFromSet()

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
	SignalBus.connect("lanternflyFeering", func(fly): percievedBodies.erase(fly))
	
func _physics_process(_delta):
	_prevPosition = global_position
	velocity = velocityComponent.handleExistingVelocity(self.velocity)
	look_at(velocity.normalized() + position)
	move_and_slide()
	distanceMoved = _prevPosition.distance_to(global_position)
	
func _process(_delta):
	var blackLikeness = ColorUtils.scoreColorLikeness(lavityLight.light.color, Color.BLACK)
	if blackLikeness > 0.80:
		SignalBus.emit_signal("fireflyFreeing", self)
		queue_free()
	if ColorUtils.scoreColorLikeness(lavityLight.light.color, targetColor) < 0.9:
		lavityLight.light.color = ColorUtils.healTowardsTarget(lavityLight.light.color, targetColor)
