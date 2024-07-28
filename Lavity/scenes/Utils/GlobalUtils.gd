extends Node
class_name GlobalUtilsClass

const MAX_RGB := 7.0
const MIN_RGB := 0.0

func randColorInRange(maxRgb=MAX_RGB):
	return randf_range(MIN_RGB, maxRgb)
	
func randColor(maxRgb=MAX_RGB) -> Color:
	return Color(randColorInRange(maxRgb), randColorInRange(maxRgb), randColorInRange(maxRgb))
