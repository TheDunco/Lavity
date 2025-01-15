extends Area2D
class_name EntityGravityArea

@export var Entity: CharacterBody2D = null

@export_category("Gravity")
# The force of gravity emitted by the light
@export var lavity := 9.8
@export var distanceMult := 75

@export_category("Color Absorbption")
@export var absorbtionMult := 0.2

var isEntityInGravityArea := false

func _ready():
	assert(Entity != null)
	connect("area_entered", handleAreaEntered)
	connect("area_exited", handleAreaExited)

# { "area": Area2D, "light": PointLight2D }
var areasWithLavityEmitter = []

@onready var absorbingLight = COLOR_UTILS.getPlayerLikeLight(Entity)

func handleAreaEntered(area: Area2D):
	var lavityPointLight: PointLight2D = area.find_parent("LavityLightLight")
	if lavityPointLight:
		areasWithLavityEmitter.append({ "area": area, "light": lavityPointLight })

func handleAreaExited(area: Area2D):
	areasWithLavityEmitter = areasWithLavityEmitter.filter(func(it): return it.area != area)

func applyGravityToEntity(area: Area2D, energy: float):
	var distance = area.global_position.distance_to(Entity.global_position)
	var magnitude = (energy * lavity) / (distance / distanceMult)
	
	var areaToEntityVector: Vector2 = area.global_position.direction_to(Entity.global_position)
	
	Entity.velocity += areaToEntityVector * magnitude

func absorbLight(emitting: PointLight2D, absorbing: PointLight2D, delta: float = 1.0):
	var rComponent = emitting.color.r * absorbtionMult * delta
	var gComponent = emitting.color.g * absorbtionMult * delta
	var bComponent = emitting.color.b * absorbtionMult * delta
	
	if absorbing.color.r  + rComponent < 1.0:
		absorbing.color.r += rComponent
	if absorbing.color.g + gComponent < 1.0:
		absorbing.color.g += gComponent
	if absorbing.color.b  + bComponent < 1.0:
		absorbing.color.b += bComponent

func _process(delta):
	if areasWithLavityEmitter.size() > 0:
		for a in areasWithLavityEmitter:
			var area: Area2D = a.area
			var lavityEmitter: PointLight2D = a.light
				
			# Entities absorbing color become visible
			absorbingLight.enabled = true

			absorbLight(lavityEmitter, absorbingLight, delta)
			applyGravityToEntity(area, lavityEmitter.energy)
