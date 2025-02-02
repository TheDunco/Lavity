extends RepulsableBody
class_name Enemy

@export var acceleration := 25.0
@export var playAnimatedSprite := true

@onready var flippingSprite := $FlippingSprite
@onready var velocityComponent: VelocityComponent = $VelocityComponent

var prevDistanceToPlayer := 0.0

enum EnemyType {
	BUG,
	AMPHIBIAN
}
var type: EnemyType = EnemyType.BUG
# Should be static per enemy type. random for base class
var preferredMoteColor = ColorUtils.randColorFromSet()

func moveToward(pos: Vector2) -> void:
	velocity += global_position.direction_to(pos) * (acceleration + (global_position.distance_to(pos) * (1/100)))

func _ready():
	super._ready()
	if playAnimatedSprite:
		flippingSprite.play()
	
	
func _process(_delta):
	flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(velocity)

func _physics_process(_delta: float) -> void:
	look_at(velocity.normalized() + position)
