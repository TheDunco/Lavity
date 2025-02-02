extends DirectionalLight2D
class_name DirectonalDarkness

func _ready() -> void:
	var darkness = Settings.getSetting("DARKNESS")
	print_debug("darkness: ", darkness)
	color.a = darkness
