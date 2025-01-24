extends Enemy
class_name Lanternfly

@export var timeToStuck := 5
@export var lanternflyAcceleration := 10.0
@export var wingFlapSpeedMult := 1.3

@onready var damageArea := $DamageArea
@onready var lanternlight := $Lanternlight
@onready var perceptionArea := $PerceptionArea
@onready var stateLabel := $StateLabel

enum States {
	IDLE,
	SEARCHING_FOR_PLAYER,
	SEARCHING_FOR_MOTE,
	STUCK
}

var state = States.IDLE

var percievedMotes: Array[Mote] = []
var percievedPlayer: Player = null

var timeNotMovingTowardObjective := 0.0

func onPerceptionAreaEntered(body: Node2D) -> void:
	if body is RigidBody2D:
		var parent = body.get_parent()
		if parent is Mote:
			print("Lanternfly percieved mote", parent)
			percievedMotes.append(parent)
			changeState(States.SEARCHING_FOR_MOTE)
	elif body is Player:
		if percievedPlayer == null:
			percievedPlayer = body
			if state != States.SEARCHING_FOR_MOTE:
				changeState(States.SEARCHING_FOR_PLAYER)
		percievedPlayer = body

func onPerceptionAreaExited(body: Node2D) -> void:
	if body is Mote:
		percievedMotes.erase(body)
		if percievedMotes.size() == 0 and state == States.SEARCHING_FOR_MOTE:
			if percievedPlayer:
				changeState(States.SEARCHING_FOR_PLAYER)
			else:
				changeState(States.IDLE)
	elif body is Player:
		percievedPlayer = null
		if state == States.SEARCHING_FOR_PLAYER:
			changeState(States.IDLE)

func _ready() -> void:
	super._ready()
	perceptionArea.connect("body_entered", onPerceptionAreaEntered)
	perceptionArea.connect("body_exited", onPerceptionAreaExited)
	acceleration = lanternflyAcceleration
	preferredMoteColor = COLOR_UTILS.RED

func moveToward(pos: Vector2) -> void:
	look_at(pos)
	velocity += global_position.direction_to(pos) * (acceleration + global_position.distance_to(pos) * (1/100))

func changeState(newState: States) -> void:
	state = newState
	match newState:
		States.IDLE:
			stateLabel.text = "Idle"
			SignalBus.emit_signal("displayHeroText", "[wave]Lanternfly:[/wave] Idle")
		States.SEARCHING_FOR_PLAYER:
			stateLabel.text = "Searching for player"
			SignalBus.emit_signal("displayHeroText", "[wave]Lanternfly:[/wave] Searching for player")
		States.SEARCHING_FOR_MOTE:
			stateLabel.text = "Searching for mote"
			SignalBus.emit_signal("displayHeroText", "[wave]Lanternfly:[/wave] Searching for mote")
		States.STUCK:
			stateLabel.text = "Stuck"
			SignalBus.emit_signal("displayHeroText", "[wave]Lanternfly:[/wave] Stuck")
		_:
			SignalBus.emit_signal("displayHeroText", "[wave]Lanternfly:[/wave] Stuck")
			stateLabel.text = "UNKNOWN"

var lastKnownPlayerPosition: Vector2 = Vector2.ZERO
var distanceToPlayer := 0.0
func moveTowardPlayer(delta: float) -> void:
	if percievedPlayer:
		lastKnownPlayerPosition = percievedPlayer.global_position

		var currentDistanceToPlayer = global_position.distance_to(lastKnownPlayerPosition)
		moveToward(lastKnownPlayerPosition)
		if currentDistanceToPlayer < distanceToPlayer:
			timeNotMovingTowardObjective = 0.0
		else:
			if timeNotMovingTowardObjective < timeToStuck:
				timeNotMovingTowardObjective += delta
			else:
				timeNotMovingTowardObjective = 0.0
				if percievedMotes.size() > 0:
					changeState(States.SEARCHING_FOR_MOTE)
				else:
					changeState(States.STUCK)
			
		distanceToPlayer = currentDistanceToPlayer

func scoreMote(mote: Mote) -> float:
	var moteColorScore = COLOR_UTILS.scoreColorLikeness(mote.getLightColor(), preferredMoteColor)
	# var moteDistanceScore = global_position.distance_to(mote.global_position)

	return moteColorScore

func checkMote(mote) -> bool:
	if not is_instance_valid(mote) or mote.is_queued_for_deletion():
		if preferredMote == mote:
			preferredMote = null
		percievedMotes.erase(mote)
		return false
	return true

func setPreferredMode() -> void:
	print("preferredMote: ", preferredMote)
	var numPerceivedMotes = percievedMotes.size()

	if numPerceivedMotes == 0:
		preferredMote = null
		return

	if numPerceivedMotes == 1:
		var newPreferredMote = percievedMotes[0]
		if checkMote(newPreferredMote):
			preferredMote = newPreferredMote
	elif numPerceivedMotes > 1:
			for mote in percievedMotes:
				if checkMote(mote) and checkMote(preferredMote) and scoreMote(mote) > scoreMote(preferredMote):
					preferredMote = mote

var preferredMote: Mote = null
var distanceToPreferredMote := 0.0
func moveTowardPreferredMote(delta: float) -> void:
	if preferredMote and checkMote(preferredMote):
		var currentDistanceToMote = global_position.distance_to(preferredMote.global_position)
		moveToward(preferredMote.global_position)

		if currentDistanceToMote < distanceToPreferredMote:
			timeNotMovingTowardObjective = 0.0
		else:
			if timeNotMovingTowardObjective < timeToStuck:
				timeNotMovingTowardObjective += delta
			else:
				timeNotMovingTowardObjective = 0.0
				if percievedPlayer:
					changeState(States.SEARCHING_FOR_PLAYER)
				else:
					changeState(States.STUCK)
			
		distanceToPreferredMote = currentDistanceToMote

func _process(_delta: float):
	flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(velocity) * wingFlapSpeedMult

	# State priority
	# The Lanternfly will prioritize motes over the player if it sees both
	# This is because, evolutionarily, it would prioritize the low hanging fruit vs something that will fight back or run away
	# It also makes the player have to fight for the motes with the Lanternflies as well as fight them which is fun
	if state == States.SEARCHING_FOR_PLAYER and (not percievedMotes.is_empty() or checkMote(preferredMote)):
		changeState(States.SEARCHING_FOR_MOTE)
	elif state == States.SEARCHING_FOR_MOTE and (percievedMotes.is_empty() or not checkMote(preferredMote)) and percievedPlayer:
		changeState(States.SEARCHING_FOR_PLAYER)
	

func _physics_process(delta: float) -> void:
	velocity = velocityComponent.handleExistingVelocity(self.velocity)
	match state:
		States.IDLE:
			# TODO: roam around until player or mote is percieved (or change process mode to idle to save resources)
			pass
		States.SEARCHING_FOR_PLAYER:
			moveTowardPlayer(delta)
		States.SEARCHING_FOR_MOTE:
			moveTowardPreferredMote(delta)
			setPreferredMode()
		States.STUCK:
			pass
	move_and_slide()
		
