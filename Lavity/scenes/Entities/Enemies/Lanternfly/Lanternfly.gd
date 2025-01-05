extends Enemy

var vampiricBoost := 0.1

@onready var flippingSprite := $FlippingSprite
@onready var velocityComponent := $VelocityComponent
@onready var damageArea := $DamageArea
@onready var lanternlight := $Lanternlight

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
		
