extends Line2D

@export var numSegments := 8
@export var segmentLength := 100
@export var startingPos := Vector2(0, 0)
@export var followMouse := false
@export var pointScale := 5

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in numSegments:
		add_point(Vector2(startingPos.x + i * segmentLength, startingPos.y + i * segmentLength), i)


func _physics_process(_delta):
	var pointCount = get_point_count()
	var mousePos = get_global_mouse_position()
	
	for pointIndex in pointCount - 1:
		if pointIndex == 0 and followMouse:
			set_point_position(pointIndex, mousePos)
		var currentPointPos = get_point_position(pointIndex)
		var nextPointPos = get_point_position(pointIndex + 1)
		var distanceBetweenPoints = currentPointPos.distance_to(nextPointPos)
		var newPointPos = nextPointPos - (currentPointPos.direction_to(nextPointPos)) * (distanceBetweenPoints - segmentLength)
		set_point_position(pointIndex + 1, newPointPos)
	
		
func _draw():
	var pointCount = get_point_count()
	for pointIndex in pointCount:
		var pointPosition = get_point_position(pointIndex)
		draw_circle(pointPosition, width_curve.sample(remap(pointIndex, 0, pointCount, 0, 1)) * pointScale, Color.BROWN)
