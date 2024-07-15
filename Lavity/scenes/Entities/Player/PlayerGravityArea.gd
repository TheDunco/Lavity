extends Area2D

# The force of gravity emitted by the light
const LAVITY := 9.8 * 2
const DISTANCE_MULT := 75

func processLavityAreaCollisions():
	var areas = get_overlapping_areas()
	var entity: CharacterBody2D = $".."

	for area in areas:
		var lavityEmitter: Light2D = area.find_parent("LavityLightLight")
		if lavityEmitter == null:
			return
			
		var areaPosition = area.global_position
		var distance = areaPosition.distance_to(entity.global_position)
			
		var magnitude = (lavityEmitter.energy * LAVITY) / (distance / DISTANCE_MULT)
		
		var areaToEntityVector: Vector2 = area.global_position.direction_to(entity.global_position)
		
		entity.velocity += areaToEntityVector * magnitude

func _process(_delta):
	processLavityAreaCollisions()
