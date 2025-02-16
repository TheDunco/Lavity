extends Enemy
class_name Lanternfly

const moteScene = preload("res://scenes/Objects/Mote.tscn")
const particlesScene = preload("res://scenes/Entities/Enemies/Lanternfly/LanternflyDeathParticles.tscn")

@export var timeToStuck := 5
@export var lanternflyBaseAcceleration := 15.0
@export var wingFlapSpeedMult := 1.3
@export var lanternLightDecayRate := 0.00007
@export var initTimeToLive := 7.0
var ttl := initTimeToLive

@onready var lanternlight := $Lanternlight
@onready var perceptionArea := $PerceptionArea
@onready var stateLabel := $StateLabel
@onready var buzzSound := $Buzz
@onready var popSound := $Pop
@onready var cpuParticles: CPUParticles2D = $CPUParticles2D

var percievedMotes: Array[Mote] = []
var percievedPlayer: Player = null
var percievedFireflies: Array[Firefly] = []

func onPerceptionAreaEntered(body: Node2D) -> void:
	if body is RigidBody2D:
		var parent = body.get_parent()
		if parent is Mote:
			percievedMotes.append(parent)
	elif body is Player:
		if percievedPlayer == null:
			percievedPlayer = body
	elif body is Firefly:
		percievedFireflies.append(body)

func onPerceptionAreaExited(body: Node2D) -> void:
	if body is RigidBody2D:
		percievedMotes.erase(body.get_parent())
	elif body is Firefly:
		percievedFireflies.erase(body)

func _ready() -> void:
	super._ready()
	self.add_to_group("lanternflies")
	perceptionArea.connect("body_entered", onPerceptionAreaEntered)
	perceptionArea.connect("body_exited", onPerceptionAreaExited)
	acceleration = lanternflyBaseAcceleration
	preferredMoteColor = ColorUtils.RED

	SignalBus.connect("moteFreeing", func(mote): percievedMotes.erase(mote))
	buzzSound.pitch_scale = randf_range(0.8, 1.2)

func scoreLightDesire(lightEmitter) -> float:
	if not lightEmitter or not lightEmitter.has_method("getLightColor"):
		return 0.0
	var moteColorScore = ColorUtils.scoreColorLikeness(lightEmitter.getLightColor(), preferredMoteColor)

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

func getPreferredFirefly() -> Firefly:
	var ret = null
	for firefly in percievedFireflies:
		if scoreLightDesire(firefly.lavityLight.light) > scoreLightDesire(firefly.lavityLight.light):
			ret = firefly
	if ret == null and not percievedFireflies.is_empty():
		return percievedFireflies[0]
	return ret
	
func getBuzzVolumeFromVelocity() -> float:
	var veloScore = abs(velocity.x) + abs(velocity.y)
	return max(remap(veloScore, 0, 2 * velocityComponent.maxVelocity, -25.0, -10.0), -10.0)

func setAccelerationFromLightColor() -> void:
	var lightSum = ColorUtils.sumColor(lanternlight.color)
	acceleration = remap(lightSum, 0.0, 3.0, lanternflyBaseAcceleration, lanternflyBaseAcceleration * 2.0)

const DEATH_MOTE_IMPULSE := 2000
func spawnDeathMotes():
	var particles = particlesScene.instantiate()
	particles.global_position = global_position
	get_tree().root.add_child(particles)
	particles.emitting = true

	for i in randi_range(1, 5):
		var deathMote = moteScene.instantiate()
		deathMote.global_position = global_position
		get_tree().root.add_child(deathMote)
		deathMote.changeColor(preferredMoteColor)
		deathMote.rigidBody.apply_central_impulse(Vector2(i * randi_range(-DEATH_MOTE_IMPULSE, DEATH_MOTE_IMPULSE), i * randi_range(-DEATH_MOTE_IMPULSE, 200)))
		# TODO: Why is this not playing a sound?

		popSound.pitch_scale = remap(i, 1, 5, 0.5, 1.5)
		popSound.playing = true


func _process(delta: float):
	lanternlight.color = ColorUtils.takeGeneralColorDamage(lanternlight.color, lanternLightDecayRate)
	buzzSound.volume_db = getBuzzVolumeFromVelocity()
	setAccelerationFromLightColor()
	cpuParticles.color = lanternlight.color
	cpuParticles.color.a = GlobalConfig.ENTITY_PARTICLES_ALPHA
	if ColorUtils.isColorDying(lanternlight.color):
		ttl -= delta
		if ttl < 0.0:
			spawnDeathMotes()
			SignalBus.emit_signal("lanternflyFreeing", self)
			queue_free()
	else:
		ttl = initTimeToLive

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(velocity) * wingFlapSpeedMult
	velocity = velocityComponent.handleExistingVelocity(self.velocity)
	move_and_slide()
