extends Node
class_name GlobalUtilsClass

const MAX_RAND_RGB := 7.0
const MIN_RAND_RGB := 0.0

const RED = Color(1, 0, 0, 1) # Health
const RED_ORANGE = Color(1, 0.35, 0, 1)
const ORANGE = Color(1, 0.65, 0, 1) # Damage?
const YELLOW_ORANGE = Color(1, 0.8, 0, 1)
const YELLOW = Color(1, 1, 0, 1) # Vision
const YELLOW_GREEN = Color(0.65, 1, 0, 1)
const GREEN = Color(0, 1, 0, 1) # Speed
const BLUE_GREEN = Color(0, 0.65, 0.65, 1)
const BLUE = Color(0, 0, 1, 1) # Sonar
const BLUE_PURPLE = Color(0.5, 0, 1, 1) # Stealth
const PURPLE = Color(0.8, 0, 0.8, 1) 
const PINK = Color(0.8, 0, 0.65, 1) # Regeneration

const colorsArray := [RED, RED_ORANGE, ORANGE, YELLOW_ORANGE, YELLOW, YELLOW_GREEN, GREEN, BLUE_GREEN, BLUE, BLUE_PURPLE, PURPLE, PINK]
const colorNames := ["red", "red_orange", "orange", "yellow_orange", "yellow", "yellow_green", "green", "blue_green", "blue", "blue_purple", "purple", "pink"]

const colors = {
	"red": RED,
	"red_orange": RED_ORANGE,
	"orange": ORANGE,
	"yellow_orange": YELLOW_ORANGE,
	"yellow": YELLOW,
	"yellow_green": YELLOW_GREEN,
	"green": GREEN,
	"blue_green": BLUE_GREEN,
	"blue": BLUE,
	"blue_purple": BLUE_PURPLE,
	"purple": PURPLE,
	"pink": PINK
}

func randColorInRange(maxRgb := MAX_RAND_RGB) -> float:
	return randf_range(MIN_RAND_RGB, maxRgb)
	
func randColor(maxRgb := MAX_RAND_RGB) -> Color:
	return Color(randColorInRange(maxRgb), randColorInRange(maxRgb), randColorInRange(maxRgb))

# Given two colors, return a score of how similar they are
func scoreColorLikeness(color1: Color, color2: Color) -> float:
	# Calculate the difference between the RGB values of the two colorswwwwwwwwww
	var rDiff = abs(color1.r - color2.r)
	var gDiff = abs(color1.g - color2.g)
	var bDiff = abs(color1.b - color2.b)

	# Calculate the average difference
	var avgDiff: float = (rDiff + gDiff + bDiff) / 3.0

	# Calculate the score based on the average difference
	return 1.0 - avgDiff

func getStatsFromColor(currentColor: Color) -> Dictionary:
	var statsPerColor := {}
	
	# Figure out how similar to each color we are
	for colorName in colorNames:
		var score := scoreColorLikeness(currentColor, colors[colorName])
		statsPerColor[colorName] = score

	# Map that to the stats
	var stats := {
		"health": statsPerColor["red"],
		"damage" : statsPerColor["orange"],
		"speed": statsPerColor["green"],
		"sonar": statsPerColor["blue"],
		"stealth": statsPerColor["blue_purple"],
		"vision": statsPerColor["yellow"],
		"regeneration": statsPerColor["pink"],
	}

	return stats
