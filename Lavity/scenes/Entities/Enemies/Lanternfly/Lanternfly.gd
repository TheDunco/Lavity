extends Enemy

func _process(delta):
	var areas = $DamageArea.get_overlapping_areas()
	for area in areas:
		if area.name == "DamageableArea":
			area.get_parent().takeDamage(damageMult * (1-delta))
			break
		
