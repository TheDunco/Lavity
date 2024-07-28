extends Area2D

# The force of gravity emitted by the light
const LAVITY := 9.8 * 2
const DISTANCE_MULT := 75

@export var Entity: CharacterBody2D = null
var isEntityInGravityArea := false
var isPlayerLike := false

const ABSORBTION_MULT := 0.001

func _ready():
	isPlayerLike = Entity is Player or Entity is Roamer or Entity is Enemy
	assert(Entity != null)

func getPlayerLikeLight() -> PointLight2D:
	if Entity is Player:
		return Entity.find_child("PlayerLight", false)
	elif Entity is Roamer:
		return Entity.find_child("RandColorLight", false)
	elif Entity is Enemy:
		return Entity.find_child("LavityLightLight")
	return null

func _process(_delta):
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
				var playerLikeLight = getPlayerLikeLight()
				
				if playerLikeLight == null:
					continue

				if playerLikeLight.color.r < 1.0:
					playerLikeLight.color.r += lavityEmitter.color.r * ABSORBTION_MULT * lavityEmitter.energy
					# lavityEmitter.color.r -= (lavityEmitter.color.r * ABSORBTION_MULT) / 2
				if playerLikeLight.color.g < 1.0:
					playerLikeLight.color.g += lavityEmitter.color.g * ABSORBTION_MULT * lavityEmitter.energy
					# lavityEmitter.color.g -= (lavityEmitter.color.g * ABSORBTION_MULT) / 2
				if playerLikeLight.color.b < 1.0:
					playerLikeLight.color.b += lavityEmitter.color.b * ABSORBTION_MULT * lavityEmitter.energy
					# lavityEmitter.color.b -= (lavityEmitter.color.b * ABSORBTION_MULT) / 2

			# Gravity
			var areaPosition = area.global_position
			var distance = areaPosition.distance_to(Entity.global_position)
			var magnitude = (lavityEmitter.energy * LAVITY) / (distance / DISTANCE_MULT)
			
			var areaToEntityVector: Vector2 = area.global_position.direction_to(Entity.global_position)
			
			Entity.velocity += areaToEntityVector * magnitude
	else:
		isEntityInGravityArea = false
	Entity.move_and_slide()
