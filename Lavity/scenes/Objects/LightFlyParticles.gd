extends CPUParticles2D
class_name LightFlyParticles

const VEC_RANGE := 360

func randDir() -> Vector2:
	return Vector2(randi_range( - VEC_RANGE, VEC_RANGE), randi_range( - VEC_RANGE, VEC_RANGE)).normalized()

func _process(_delta):
	direction = randDir()
