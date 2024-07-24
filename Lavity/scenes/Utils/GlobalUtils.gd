extends Node
class_name GlobalUtilsClass

func randColorInRange(minRgb=0.0, maxRgb=50.0):
	return randf_range(minRgb, maxRgb)
	
func randColor(minRgb=0.0, maxRgb=50.0) -> Color:
	var color = Color(randColorInRange(minRgb, maxRgb), randColorInRange(minRgb, maxRgb), randColorInRange(minRgb, maxRgb))
	print(color)
	return color
