extends Area2D
class_name EntityGravityArea

@export var Entity: CharacterBody2D = null

@export_category("Gravity")
# The force of gravity emitted by the light
@export var lavity := 9.8 * 2
@export var distanceMult := 75

@export_category("Color Absorbption")
@export var absorbtionMult := 0.2

var isEntityInGravityArea := false
var isPlayerLike := false

func _ready():
	isPlayerLike = Entity is Player or Entity is Roamer or Entity is Enemy or Entity
	assert(Entity != null)

func _process(delta):
	var areas = get_overlapping_areas()
	
	if areas.size() > 0:
		isEntityInGravityArea = true

		for area in areas:
			# Light absorption
			var lavityEmitter: PointLight2D = area.find_parent("LavityLightLight")
			if lavityEmitter == null:
				print("EntityGravityArea.gd: lavityEmitter not found")
				continue

				
			if isPlayerLike:
				var playerLikeLight = GLOBAL_UTILS.getPlayerLikeLight(Entity)
				
				if playerLikeLight == null:
					continue
				
				playerLikeLight.enabled = true
				
				var rComponent = lavityEmitter.color.r * absorbtionMult * delta
				var gComponent = lavityEmitter.color.g * absorbtionMult * delta
				var bComponent = lavityEmitter.color.b * absorbtionMult * delta
				
				if playerLikeLight.color.r  + rComponent < 1.0:
					playerLikeLight.color.r += rComponent
				if playerLikeLight.color.g + gComponent < 1.0:
					playerLikeLight.color.g += gComponent
				if playerLikeLight.color.b  + bComponent < 1.0:
					playerLikeLight.color.b += bComponent

			# Gravity
			var areaPosition = area.global_position
			var distance = areaPosition.distance_to(Entity.global_position)
			var magnitude = (lavityEmitter.energy * lavity) / (distance / distanceMult)
			
			var areaToEntityVector: Vector2 = area.global_position.direction_to(Entity.global_position)
			
			Entity.velocity += areaToEntityVector * magnitude
	else:
		isEntityInGravityArea = false
	Entity.move_and_slide()
