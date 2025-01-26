extends Enemy
class_name Lanternfly

# State priority
# The Lanternfly will prioritize motes over the player if it sees both
# This is because, evolutionarily, it would prioritize the low hanging fruit vs something that will fight back or run away
# It also makes the player have to fight for the motes with the Lanternflies as well as fight them which is fun

@export var timeToStuck := 5
@export var lanternflyBaseAcceleration := 15.0
@export var wingFlapSpeedMult := 1.3
@export var lanternLightDecayRate := 0.00007
@export var initTimeToLive := 7.0
var ttl := initTimeToLive

@onready var damageArea := $DamageArea
@onready var lanternlight := $Lanternlight
@onready var perceptionArea := $PerceptionArea
@onready var stateLabel := $StateLabel
@onready var buzzSound := $Buzz
 
var percievedMotes: Array[Mote] = []
var percievedPlayer: Player = null

func onPerceptionAreaEntered(body: Node2D) -> void:
	if body is RigidBody2D:
		var parent = body.get_parent()
		if parent is Mote:
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
	acceleration = lanternflyBaseAcceleration
	preferredMoteColor = COLOR_UTILS.RED

	SignalBus.connect("moteFreeing", func(mote): percievedMotes.erase(mote))
	buzzSound.pitch_scale = randf_range(0.8, 1.2)


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
	
func getBuzzVolumeFromVelocity() -> float:
	var veloScore = abs(velocity.x) + abs(velocity.y)
	return remap(veloScore, 0, 2*velocityComponent.maxVelocity, -20.0, -11.0)

func setAccelerationFromLightColor() -> void:
	var lightSum = COLOR_UTILS.sumColor(lanternlight.color)
	acceleration = remap(lightSum, 0.0, 3.0, lanternflyBaseAcceleration, lanternflyBaseAcceleration * 2.0)

func _process(delta: float):
	lanternlight.color = COLOR_UTILS.takeGeneralColorDamage(lanternlight.color, lanternLightDecayRate)
	buzzSound.volume_db = getBuzzVolumeFromVelocity()
	setAccelerationFromLightColor()
	if COLOR_UTILS.isColorDying(lanternlight.color):
		ttl -= delta
		if ttl < 0.0:
			queue_free()
	else:
		ttl = initTimeToLive


func _physics_process(_delta: float) -> void:
	flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(velocity) * wingFlapSpeedMult
	velocity = velocityComponent.handleExistingVelocity(self.velocity)
	move_and_slide()
		
