extends DirectionalLight2D
class_name DirectonalDarkness

func _ready() -> void:
	var darkness = Settings.getSetting("DARKNESS")
	color.a = darkness
