extends Node2D
class_name MazeDoor

@onready var maze: ProceduralMaze = get_parent()
@onready var sprite: Sprite2D = $Sprite2D
@onready var collisionShape: CollisionShape2D = $ColorPassableArea/CollisionShape2D
@onready var textureLight: PointLight2D = $TextureLight
@onready var colorPassableArea = $ColorPassableArea

var doorPoint: Vector2
@onready var middlePoints = maze.getTileCenters()

func onPass(player: Player) -> void:
	print("MazeDoor onPass ", player.name)
	# TODO: Incrementally ramp up maze difficulty by increasing size, decreasing mote spawn chance, increasing enemies
	GameFlow.switchScene("res://scenes/Ui/Menu2D.tscn")


func setDoorPoint():
	doorPoint = middlePoints.pick_random()
	# If the atlas of this point is (3, 3) then it's impossible to get to the door so we need to choose a new one
	if maze.get_cell_atlas_coords(0, doorPoint) == Vector2i(maze.tilemapSizeX - 1, maze.tilemapSizeY - 1):
		setDoorPoint()

func _ready() -> void:
	var doorWidth = maze.tile_set.tile_size.x / 2
	var doorHeight = maze.tile_set.tile_size.y / 2
	var doorSize = Vector2(doorWidth, doorHeight)
	
	sprite.texture.width = doorWidth
	sprite.texture.height = doorHeight
	textureLight.texture.width = doorWidth
	textureLight.texture.height = doorHeight
	collisionShape.shape.size = doorSize
	
	var passColor = COLOR_UTILS.randColorFromSet()
	colorPassableArea.color = passColor
	textureLight.color = passColor

	setDoorPoint()
	
	global_position = doorPoint
	SignalBus.connect("playerPassedMaze", onPass)
	
func rand() -> float:
	return randf_range(-1.0, 1.0)

func _process(delta: float) -> void:
	sprite.texture.noise.offset.x += rand()
	sprite.texture.noise.offset.y += rand()
	textureLight.texture.noise.offset.x += rand()
	textureLight.texture.noise.offset.y += rand()
