extends Enemy
class_name Lanternfly

@export var timeToStuck := 5
@export var lanternflyAcceleration := 10.0

@onready var damageArea := $DamageArea
@onready var lanternlight := $Lanternlight
@onready var perceptionArea := $PerceptionArea
@onready var stateLabel := $StateLabel

# I'm thinking that the Lanternfly will prioritize motes over the player if it sees both
# This is because, evolutionarily, it would prioritize the low hanging fruit vs something that will fight back or run away
# It also makes the player have to fight for the motes with the Lanternflies which is fun
enum States {
	IDLE,
	SEARCHING_FOR_PLAYER,
	SEARCHING_FOR_MOTE,
	STUCK
}

var state = States.IDLE

var percievedMotes: Array[Mote] = []
var percievedPlayer: Player = null

func onPerceptionAreaEntered(body: Node2D) -> void:
	if body is Mote:
		percievedMotes.append(body)
		if state == States.IDLE:
			changeState(States.SEARCHING_FOR_MOTE)
	elif body is Player:
		if percievedPlayer == null:
			percievedPlayer = body
			if state == States.IDLE:
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
var timeNotMovingTowardPlayer := 0.0
func moveTowardPlayer(delta: float) -> void:
	if percievedPlayer:
		lastKnownPlayerPosition = percievedPlayer.global_position

		var currentDistanceToPlayer = global_position.distance_to(lastKnownPlayerPosition)
		moveToward(lastKnownPlayerPosition)
		if currentDistanceToPlayer < distanceToPlayer:
			timeNotMovingTowardPlayer = 0.0
		else:
			if timeNotMovingTowardPlayer < timeToStuck:
				timeNotMovingTowardPlayer += delta
			else:
				changeState(States.STUCK)
				timeNotMovingTowardPlayer = 0.0
			
		distanceToPlayer = currentDistanceToPlayer

func _process(delta: float):
	super._process(delta)
	

func _physics_process(delta: float) -> void:
	velocity = velocityComponent.handleExistingVelocity(self.velocity)
	match state:
		States.IDLE:
			# TODO: roam around until player or mote is percieved (or change process mode to idle to save resources)
			pass
		States.SEARCHING_FOR_PLAYER:
			moveTowardPlayer(delta)
		States.SEARCHING_FOR_MOTE:
			# TODO: Decide which mote is preferable and move toward it
			pass
		States.STUCK:
			pass
	move_and_slide()
		
