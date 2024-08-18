extends Enemy

var vampiricBoost := 0.1

func _process(delta):
	var areas = $DamageArea.get_overlapping_areas()
	if vampiricBoost > 0.1:
		vampiricBoost -= 0.08 * delta
	var lightScale = 1/log(vampiricBoost/2)/2
	$Lanternlight.scale = Vector2(lightScale, lightScale)
		
	for area in areas:
		if area.name == "DamageableArea":
			var didDamage = area.get_parent().takeDamage(damageMult * (1-delta))
			if didDamage:
				vampiricBoost += damageMult
			break
		
