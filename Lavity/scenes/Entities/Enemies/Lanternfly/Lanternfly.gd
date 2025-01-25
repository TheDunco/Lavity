extends Enemy
class_name Lanternfly

# State priority
# The Lanternfly will prioritize motes over the player if it sees both
# This is because, evolutionarily, it would prioritize the low hanging fruit vs something that will fight back or run away
# It also makes the player have to fight for the motes with the Lanternflies as well as fight them which is fun

@export var timeToStuck := 5
@export var lanternflyAcceleration := 10.0
@export var wingFlapSpeedMult := 1.3

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
	if body is Mote:
		percievedMotes.erase(body)
	elif body is Player:
		percievedPlayer = null

func _ready() -> void:
	super._ready()
	perceptionArea.connect("body_entered", onPerceptionAreaEntered)
	perceptionArea.connect("body_exited", onPerceptionAreaExited)
	acceleration = lanternflyAcceleration
	preferredMoteColor = COLOR_UTILS.RED

func moveToward(pos: Vector2) -> void:
	look_at(pos)
	velocity += global_position.direction_to(pos) * (acceleration + (global_position.distance_to(pos) * (1/100)))

func scoreMote(mote) -> float:
	if not mote:
		return 0.0
	var moteColorScore = COLOR_UTILS.scoreColorLikeness(mote.getLightColor(), preferredMoteColor)
	# var moteDistanceScore = global_position.distance_to(mote.global_position)

	return moteColorScore

func checkMote(mote) -> bool:
	if not mote or mote.is_queued_for_deletion():
		percievedMotes.erase(mote)
		return false
	return true

func _process(_delta: float):
	flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(velocity) * wingFlapSpeedMult
	for mote in percievedMotes:
		checkMote(mote)

func _physics_process(_delta: float) -> void:
	velocity = velocityComponent.handleExistingVelocity(self.velocity)
	move_and_slide()
		
