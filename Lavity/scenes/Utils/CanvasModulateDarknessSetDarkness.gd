extends CanvasModulate

func _ready() -> void:
	var darkness = GLOBAL.getSetting("DARKNESS")
	if darkness:
		color.a = darkness
	else:
		print("no darkness")
