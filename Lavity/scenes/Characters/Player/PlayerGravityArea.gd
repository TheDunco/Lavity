extends Area2D

# The force of gravity emitted by the light
const LAVITY := 9.8 * 2
const DISTANCE_MULT := 75

func _process(_delta):
	var areas = get_overlapping_areas()
	var player = $".."
	
	for area in areas:
		var lavityEmitter: Light2D = area.find_parent("LavityLightLight")
		if lavityEmitter == null:
			return
			
		var areaPosition = area.global_position
		var distance = areaPosition.distance_to(player.global_position)
			
		var magnitude = (lavityEmitter.energy * LAVITY) / (distance / DISTANCE_MULT)
		
		var areaToPlayerVector: Vector2 = area.global_position.direction_to(player.global_position)
		
		player.velocity += areaToPlayerVector * magnitude
