extends Area2D

# The force of gravity emitted by the light
const LAVITY := 9.8 * 2
const DISTANCE_MULT := 75

@export var Entity: CharacterBody2D = null
var isEntityInGravityArea := false

func _ready():
	assert(Entity != null)

func _process(_delta):
	var areas = get_overlapping_areas()
	
	if areas.size() > 0:
		isEntityInGravityArea = true

		for area in areas:
			var lavityEmitter: Light2D = area.find_parent("LavityLightLight")
			if lavityEmitter == null:
				continue
				
			var areaPosition = area.global_position
			var distance = areaPosition.distance_to(Entity.global_position)
				
			var magnitude = (lavityEmitter.energy * LAVITY) / (distance / DISTANCE_MULT)
			
			var areaToEntityVector: Vector2 = area.global_position.direction_to(Entity.global_position)
			
			Entity.velocity += areaToEntityVector * magnitude
	else:
		isEntityInGravityArea = false
	Entity.move_and_slide()
