extends Area2D
class_name EntityGravityArea

@export var Entity: Node2D = null

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

# { "area": Area2D, "light": PointLight2D, "oppositeForceBody": RigidBody2D | null }
var areasWithLavityEmitter = []

@onready var absorbingLight = COLOR_UTILS.getLavityLightEmitter(Entity)

func handleAreaEntered(area: Area2D):
	var lavityPointLight: PointLight2D = area.find_parent("LavityLightLight")
	var oppositeForceBody: RigidBody2D = area.find_parent("OppositeForceBody")
	if lavityPointLight:
		areasWithLavityEmitter.append({ "area": area, "light": lavityPointLight, "oppositeForceBody": oppositeForceBody })

func handleAreaExited(area: Area2D):
	areasWithLavityEmitter = areasWithLavityEmitter.filter(func(it): return it.area != area)

func applyGravityToEntity(area: Area2D, oppositeForceBody: RigidBody2D = null, energy: float = 1.0):
	var magnitude = (energy * lavity) / (area.global_position.distance_to(Entity.global_position) / distanceMult)
	var directionToEntity: Vector2 = area.global_position.direction_to(Entity.global_position)
	
	# Apply equal force to the entity
	Entity.velocity += directionToEntity * magnitude
	# Apply opposite force to the oppositeForceBody
	if oppositeForceBody:
		oppositeForceBody.apply_central_force(-directionToEntity * magnitude)


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
			var oppositeForceBody: RigidBody2D = a.oppositeForceBody
				
			# Entities absorbing color become visible
			absorbingLight.enabled = true

			absorbLight(lavityEmitter, absorbingLight, delta)
			applyGravityToEntity(area, oppositeForceBody, lavityEmitter.energy)
