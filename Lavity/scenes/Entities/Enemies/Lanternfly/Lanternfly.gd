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

@onready var damageArea := $DamageArea
@onready var lanternlight := $Lanternlight
@onready var perceptionArea := $PerceptionArea
@onready var stateLabel := $StateLabel
@onready var buzzSound := $Buzz
@onready var cpuParticles: CPUParticles2D = $CPUParticles2D

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
	
func getBuzzVolumeFromVelocity() -> float:
	var veloScore = abs(velocity.x) + abs(velocity.y)
	return max(remap(veloScore, 0, 2*velocityComponent.maxVelocity, -20.0, -11.0), -11.0)

func setAccelerationFromLightColor() -> void:
	var lightSum = ColorUtils.sumColor(lanternlight.color)
	acceleration = remap(lightSum, 0.0, 3.0, lanternflyBaseAcceleration, lanternflyBaseAcceleration * 2.0)

const DEATH_MOTE_IMPULSE := 2000
func spawnDeathMotes():
	# This is causing issues: https://github.com/godotengine/godot/issues/52112 
	# Maybe CPU particles would work better?
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
		deathMote.pop.pitch_scale = remap(i, 1, 5, 0.7, 1.2)
		deathMote.pop.play()



func _process(delta: float):
	lanternlight.color = ColorUtils.takeGeneralColorDamage(lanternlight.color, lanternLightDecayRate)
	buzzSound.volume_db = getBuzzVolumeFromVelocity()
	setAccelerationFromLightColor()
	cpuParticles.color = lanternlight.color
	cpuParticles.color.a = 0.25;
	if ColorUtils.isColorDying(lanternlight.color):
		ttl -= delta
		if ttl < 0.0:
			spawnDeathMotes()
			queue_free()
	else:
		ttl = initTimeToLive

func _physics_process(_delta: float) -> void:
	flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(velocity) * wingFlapSpeedMult
	velocity = velocityComponent.handleExistingVelocity(self.velocity)
	move_and_slide()
		
