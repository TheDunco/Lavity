extends PointLight2D

func randColorInRange(minRgb=0.0, maxRgb=50.0):
	return randf_range(minRgb, maxRgb)

func _ready():
	color = Color(randColorInRange(), randColorInRange(), randColorInRange())

