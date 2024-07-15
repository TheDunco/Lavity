extends CPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
const VEC_RANGE := 360

func randDir() -> Vector2:
	return Vector2(randi_range( - VEC_RANGE, VEC_RANGE), randi_range( - VEC_RANGE, VEC_RANGE)).normalized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	direction = randDir()
	print(direction)
