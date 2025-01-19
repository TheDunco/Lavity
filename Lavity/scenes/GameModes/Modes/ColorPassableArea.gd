extends Area2D 

@export var color: Color = GlobalUtils.colors["yellow"]
@export var passThreshold := 5.5
@onready var shape: CollisionShape2D = get_child(0)

var player: Player = null

func _ready() -> void:
	assert(shape)
	connect("body_entered", onBodyEntered)
	color = COLOR_UTILS.randColorFromSet()

var scoringMotes: Array[Mote] = []

func sumMoteLikeness() -> float:
	var sum = 0.0
	for mote in scoringMotes:
		if !mote:
			scoringMotes.erase(mote)
			continue
		sum += COLOR_UTILS.scoreColorLikeness(mote.getLightColor(), color)
	return sum

func onBodyEntered(body: Node) -> void:
	print("ColorPassableArea onBodyEntered ", body)
	if body is RigidBody2D:
			var mote = body.get_parent() as Mote
			var likeness = COLOR_UTILS.scoreColorLikeness(mote.getLightColor(), color)
			print("ColorPassableArea var likeness = ", likeness)
			scoringMotes.append(mote)
			print("sum: ", sumMoteLikeness(), "required: ", passThreshold)
			if sumMoteLikeness() > passThreshold:
				scoringMotes.clear()
				SignalBus.emit_signal("playerPassedMaze", player)

	if body is Player and not player:
		player = body as Player
		SignalBus.emit_signal("displayHeroText", "[center]\n[wave]Objective[/wave]: Fill the portal with motes of its color to win![/center]")

func onBodyExited(body: Node) -> void:
	if body is RigidBody2D:
		var mote = body.get_parent() as Mote
		scoringMotes.erase(mote)
				
