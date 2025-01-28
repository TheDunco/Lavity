extends CanvasModulate

func _ready() -> void:
	var darkness = Settings.getSetting("DARKNESS")
	if darkness:
		color.a = darkness
	else:
		print("no darkness")
