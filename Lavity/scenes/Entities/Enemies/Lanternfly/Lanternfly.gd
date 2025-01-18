extends Enemy

var vampiricBoost := 0.1

@onready var damageArea := $DamageArea
@onready var lanternlight := $Lanternlight

# TODO: Should be static per enemy type, random for testing
var preferredMoteColor = COLOR_UTILS.colors[COLOR_UTILS.colorNames[randi() % COLOR_UTILS.colorNames.size()]]

var states = {
	"IDLE": 0,
	"SEARCHING_FOR_PLAYER": 1,
	"SEARCHING_FOR_MOTE": 2,
}

var state = states.IDLE

func _process(delta):
	flippingSprite.speed_scale = velocityComponent.getAnimationSpeed(self.velocity)

	var areas = damageArea.get_overlapping_areas()
	if vampiricBoost > 0.1:
		vampiricBoost -= 0.08 * delta
	lanternlight.scale = Vector2(vampiricBoost, vampiricBoost)
		
	for area in areas:
		if area.name == "DamageableArea":
			var didDamage = area.get_parent().takeDamage(damageMult * (1-delta))
			if didDamage:
				vampiricBoost += damageMult
			break

# func _physics_process(delta: float) -> void:
# 	pass
		
