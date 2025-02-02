extends GPUParticles2D

func _ready() -> void:
	connect("finished", func(): queue_free())
