extends Node2D
class_name MazeDoor

@onready var maze: ProceduralMaze = get_parent()
@onready var distortion: Sprite2D = $Distortion
@onready var colorSprite: Sprite2D = $Color
@onready var collisionShape: CollisionShape2D = $ColorPassableArea/CollisionShape2D
@onready var colorPassableArea: ColorPassableArea = $ColorPassableArea
@onready var distortionMovement: AnimationPlayer = $Distortion/DistortionMovement

var doorPoint: Vector2
@onready var middlePoints = maze.getTileCenters()

func onPass(player: Player) -> void:
	# TODO: Incrementally ramp up maze difficulty by increasing size, decreasing mote spawn chance, increasing enemies
	GameFlow.switchScene("res://scenes/Ui/Menu2D.tscn")
	SignalBus.emit_signal("displayHeroText", "[center][wave]\n\n\n\tYOU WIN![/wave]\nMore progression coming soon...[/center]")
	GlobalSfx.playImpulse()
	GameFlow.switchToMenuMusic()


func setDoorPoint():
	doorPoint = middlePoints.pick_random()
	# If the atlas of this point is (3, 3) then it's impossible to get to the door so we need to choose a new one
	if maze.get_cell_atlas_coords(0, doorPoint) == Vector2i(maze.tilemapSizeX - 1, maze.tilemapSizeY - 1):
		setDoorPoint()

func _ready() -> void:
	var doorWidth = maze.tile_set.tile_size.x / 2
	var doorHeight = maze.tile_set.tile_size.y / 2
	var doorSize = Vector2(doorWidth, doorHeight)
	
	distortion.texture.width = doorWidth
	distortion.texture.height = doorHeight
	colorSprite.texture.width = doorWidth
	colorSprite.texture.height = doorHeight

	collisionShape.shape.size = doorSize
	
	var passColor = ColorUtils.randColorFromSet()
	colorPassableArea.color = passColor
	
	colorSprite.texture.gradient.set_color(0, passColor)

	setDoorPoint()
	global_position = doorPoint

	SignalBus.connect("playerPassedMaze", onPass)
	distortionMovement.play("move_distortion")
	
