extends RepulsableBody
class_name Enemy

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

func _ready():
	super._ready()
	self.add_to_group("enemies")
	if playAnimatedSprite:
		flippingSprite.play()
	
	
func _process(_delta):
	flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(velocity)

func _physics_process(_delta: float) -> void:
	look_at(velocity.normalized() + position)
