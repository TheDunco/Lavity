extends Area2D
class_name EntityGravityArea

@export var entity: Node2D = null
@export var absorbingLight: PointLight2D = null

@export_category("Gravity")
# The force of gravity emitted by the light
@export var lavity := 9.8
@export var distanceMult := 500

@export_category("Color Absorbption")
@export var absorbtionMult := 0.25

var isEntityInGravityArea := false

func _ready():
	assert(entity != null)
	assert(absorbingLight != null)
	connect("area_entered", handleAreaEntered)
	connect("area_exited", handleAreaExited)

# { "area": Area2D, "light": PointLight2D, "oppositeForceBody": RigidBody2D | null, characterForceBody: CharacterBody2d | null }
var areasWithLavityEmitter = []

func handleAreaEntered(area: Area2D):
	var parent = area.get_parent()
	if parent is CharacterBody2D:
		var characterLight: PointLight2D = parent.find_children("*", "PointLight2D")[0]
		areasWithLavityEmitter.append({ "area": area, "light": characterLight, "characterForceBody": parent, "oppositeForceBody": null })
	else:
		var lavityPointLight: PointLight2D = area.find_parent("LavityLightLight")
		var oppositeForceBody: RigidBody2D = area.find_parent("OppositeForceBody")
		areasWithLavityEmitter.append({ "area": area, "light": lavityPointLight, "oppositeForceBody": oppositeForceBody, "characterForceBody": null })

func handleAreaExited(area: Area2D):
	areasWithLavityEmitter = areasWithLavityEmitter.filter(func(it): return it.area != area)

func applyGravityToEntity(area: Area2D, oppositeForceBody: RigidBody2D = null, characterForceBody: CharacterBody2D = null, energy: float = 1.0):
	var magnitude = (energy * lavity) / (area.global_position.distance_to(entity.global_position) / distanceMult)
	var directionToEntity: Vector2 = area.global_position.direction_to(entity.global_position)
	
	# Apply equal force to the entity
	entity.velocity += directionToEntity * magnitude
	# Apply opposite force to the oppositeForceBody
	if oppositeForceBody:
		oppositeForceBody.apply_central_force(-directionToEntity * magnitude)
	if characterForceBody:
		characterForceBody.velocity += -directionToEntity * magnitude


func absorbLight(emitting: PointLight2D, absorbing: PointLight2D, delta: float = 1.0):
	var rComponent = emitting.color.r * absorbtionMult * delta
	var gComponent = emitting.color.g * absorbtionMult * delta
	var bComponent = emitting.color.b * absorbtionMult * delta
	
	if absorbing.color.r  + rComponent < 1.0:
		absorbing.color.r += rComponent
		emitting.color.r -= rComponent
	if absorbing.color.g + gComponent < 1.0:
		absorbing.color.g += gComponent
		emitting.color.g -= gComponent
	if absorbing.color.b  + bComponent < 1.0:
		absorbing.color.b += bComponent
		emitting.color.b -= bComponent

func _physics_process(delta: float) -> void:
	if areasWithLavityEmitter.size() > 0:
		for a in areasWithLavityEmitter:
			var area: Area2D = a.area
			var lavityEmitter: PointLight2D = a.light
			var oppositeForceBody: RigidBody2D = a.oppositeForceBody
			var characterForceBody: CharacterBody2D = a.characterForceBody
				
			# Entities absorbing color become visible
			if absorbingLight and lavityEmitter:
				absorbingLight.enabled = true
				absorbLight(lavityEmitter, absorbingLight, delta)
				
			applyGravityToEntity(area, oppositeForceBody, characterForceBody, COLOR_UTILS.sumColor(lavityEmitter.color) / 3.0)
