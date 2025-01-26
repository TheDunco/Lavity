extends Enemy
class_name Lanternfly

# State priority
# The Lanternfly will prioritize motes over the player if it sees both
# This is because, evolutionarily, it would prioritize the low hanging fruit vs something that will fight back or run away
# It also makes the player have to fight for the motes with the Lanternflies as well as fight them which is fun

@export var timeToStuck := 5
@export var lanternflyAcceleration := 15.0
@export var wingFlapSpeedMult := 1.3
@export var lanternLightDecayRate := 0.00002

@onready var damageArea := $DamageArea
@onready var lanternlight := $Lanternlight
@onready var perceptionArea := $PerceptionArea
@onready var stateLabel := $StateLabel

var percievedMotes: Array[Mote] = []
var percievedPlayer: Player = null

func onPerceptionAreaEntered(body: Node2D) -> void:
	if body is RigidBody2D:
		var parent = body.get_parent()
		if parent is Mote:
			print("Lanternfly percieved mote", parent)
			percievedMotes.append(parent)
	elif body is Player:
		if percievedPlayer == null:
			percievedPlayer = body

func onPerceptionAreaExited(body: Node2D) -> void:
	if body is RigidBody2D:
		percievedMotes.erase(body.get_parent())

func _ready() -> void:
	super._ready()
	perceptionArea.connect("body_entered", onPerceptionAreaEntered)
	perceptionArea.connect("body_exited", onPerceptionAreaExited)
	acceleration = lanternflyAcceleration
	preferredMoteColor = COLOR_UTILS.RED

	SignalBus.connect("moteFreeing", func(mote): percievedMotes.erase(mote))


func scoreLightDesire(lightEmitter) -> float:
	if not lightEmitter or not lightEmitter.has_method("getLightColor"):
		return 0.0
	var moteColorScore = COLOR_UTILS.scoreColorLikeness(lightEmitter.getLightColor(), preferredMoteColor)

	return moteColorScore

func checkMote(mote) -> bool:
	if not mote or mote.is_queued_for_deletion():
		return false
	return true

func getPreferredMote() -> Mote:
	var ret = null
	for mote in percievedMotes:
		if scoreLightDesire(mote) > scoreLightDesire(ret):
			ret = mote
	if ret == null and not percievedMotes.is_empty():
		return percievedMotes[0]
	return ret

func _process(_delta: float):
	flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(velocity) * wingFlapSpeedMult
	lanternlight.color = COLOR_UTILS.takeGeneralColorDamage(lanternlight.color, lanternLightDecayRate)

func _physics_process(_delta: float) -> void:
	velocity = velocityComponent.handleExistingVelocity(self.velocity)
	move_and_slide()
		
