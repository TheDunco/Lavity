extends Node
class_name GlobalUtils

const MAX_RAND_RGB := 4.0
const MIN_RAND_RGB := 0.0

const RED = Color(1, 0, 0) # Health
const RED_ORANGE = Color(1, 0.5, 0)
const ORANGE = Color(1, 0.75, 0) # Hunger (player light radius)
const YELLOW_ORANGE = Color(1, 0.8, 0)
const YELLOW = Color(1, 1, 0) # Vision
const YELLOW_GREEN = Color(0.75, 1, 0)
const GREEN = Color(0, 1, 0) # Speed
const BLUE_GREEN = Color(0, 0.75, 0.75)
const BLUE = Color(0, 0, 1) # Sonar
const BLUE_PURPLE = Color(0.5, 0, 1) # Stealth
const PURPLE = Color(0.5, 0, 0.5)
const PINK = Color(1, 0, 1) # Longevity

## An array of all of the color constants
const colorsArray := [RED, RED_ORANGE, ORANGE, YELLOW_ORANGE, YELLOW, YELLOW_GREEN, GREEN, BLUE_GREEN, BLUE, BLUE_PURPLE, PURPLE, PINK]
const colorNames := [
	"red",
	"red_orange",
	"orange",
	"yellow_orange",
	"yellow",
	"yellow_green",
	"green",
	"blue_green",
	"blue",
	"blue_purple",
	"purple",
	"pink"
]

## A dictionary of the colors mapped to their snake_case names
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

## The lowest sum of a light COLOR to be considered "alive"
const LIGHT_SUM_DEATH_CUTOFF := 0.03

func isColorDying(color: Color) -> bool:
	return sumColor(color) < LIGHT_SUM_DEATH_CUTOFF

func randColorInRange(maxRgb := MAX_RAND_RGB) -> float:
	return randf_range(MIN_RAND_RGB, maxRgb)
	
func randColor(maxRgb := MAX_RAND_RGB) -> Color:
	return Color(randColorInRange(maxRgb), randColorInRange(maxRgb), randColorInRange(maxRgb))
	
func randColorFromSet() -> Color:
	return colorsArray.pick_random()

## Given two colors, return a score of how similar they are
func scoreColorLikeness(color1: Color, color2: Color) -> float:
	# Calculate the difference (distance within the color space) between the RGB values of the two colors
	var rDiff = abs(color1.r - color2.r)
	var gDiff = abs(color1.g - color2.g)
	var bDiff = abs(color1.b - color2.b)

	# Calculate the average distance
	var avgDiff: float = (rDiff + gDiff + bDiff) / 3.0

	# Likeness score is the inverse of the average distance
	return 1.0 - avgDiff

func sumColor(color: Color) -> float:
	return color.r + color.g + color.b

## Returns the absolute sum of the vector
func sumVector2(vector2: Vector2) -> float:
	return abs(vector2.x) + abs(vector2.y)

## This isn't working exactly as expected because the differences aren't normalized
## Because each color has a slightly different total RGB value, this calculation can be somewhat innacturate
## I tried calculating scores differently but it didn't work well
func getMostSimilarColor(color: Color) -> Color:
	var mostCommon: Color = colorsArray[0]
	for colorName in colorNames:
		var comparisonColor = colors[colorName]
		var currentScore = scoreColorLikeness(comparisonColor, mostCommon)
		var newScore = scoreColorLikeness(comparisonColor, color)
		if newScore > currentScore:
			mostCommon = comparisonColor
	return mostCommon
		
# Class that handles hue rotation for RGB values
# Based on https://stackoverflow.com/questions/8507885/shift-hue-of-an-rgb-color
class RGBRotate:
	var matrix: Array

	func _init():
		# Initialize the rotation matrix as an identity matrix
		matrix = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]

	# Helper function to colorClamp values between 0.0 and 1.0 for float-based RGB values
	func colorClamp(v: float) -> float:
		if v < 0.0:
			return 0.0
		if v > 1.0:
			return 1.0
		return v

	# Method to set the hue rotation based on degrees
	func set_hue_rotation(degrees: float) -> void:
		var cosA = cos(deg_to_rad(degrees)) # Using deg_to_rad for converting degrees to radians
		var sinA = sin(deg_to_rad(degrees))
		
		# Standard hue rotation matrix for RGB colors
		matrix[0][0] = cosA + (1.0 - cosA) / 3.0
		matrix[0][1] = (1.0 / 3.0) * (1.0 - cosA) - sqrt(1.0 / 3.0) * sinA
		matrix[0][2] = (1.0 / 3.0) * (1.0 - cosA) + sqrt(1.0 / 3.0) * sinA
		matrix[1][0] = (1.0 / 3.0) * (1.0 - cosA) + sqrt(1.0 / 3.0) * sinA
		matrix[1][1] = cosA + (1.0 / 3.0) * (1.0 - cosA)
		matrix[1][2] = (1.0 / 3.0) * (1.0 - cosA) - sqrt(1.0 / 3.0) * sinA
		matrix[2][0] = (1.0 / 3.0) * (1.0 - cosA) - sqrt(1.0 / 3.0) * sinA
		matrix[2][1] = (1.0 / 3.0) * (1.0 - cosA) + sqrt(1.0 / 3.0) * sinA
		matrix[2][2] = cosA + (1.0 / 3.0) * (1.0 - cosA)

	# Method to apply the hue rotation to RGB values
	func apply(color: Color) -> Color:
		var rx = color.r * matrix[0][0] + color.g * matrix[0][1] + color.b * matrix[0][2]
		var gx = color.r * matrix[1][0] + color.g * matrix[1][1] + color.b * matrix[1][2]
		var bx = color.r * matrix[2][0] + color.g * matrix[2][1] + color.b * matrix[2][2]
		GlobalSfx.playTonalClick(remap(rx, 0.0, 1.0, 0.5, 1.5))
		# Clamp the final RGB values to the range 0.0 to 1.0 and return them
		return Color(colorClamp(rx), colorClamp(gx), colorClamp(bx))

func takeGeneralColorDamage(color: Color, damage: float) -> Color:
	var newColor = color
	newColor.a = 1.0

	var numColorsThatCanTakeDamage := 0
	var rCanTakeDamage = newColor.r > 0
	var gCanTakeDamage = newColor.g > 0
	var bCanTakeDamage = newColor.b > 0

	if rCanTakeDamage:
		numColorsThatCanTakeDamage += 1
	if gCanTakeDamage:
		numColorsThatCanTakeDamage += 1
	if bCanTakeDamage:
		numColorsThatCanTakeDamage += 1
	
	if rCanTakeDamage:
		newColor.r -= damage / numColorsThatCanTakeDamage
		newColor.r = max(newColor.r, 0)
	
	if gCanTakeDamage:
		newColor.g -= damage / numColorsThatCanTakeDamage
		newColor.g = max(newColor.g, 0)

	if bCanTakeDamage:
		newColor.b -= damage / numColorsThatCanTakeDamage
		newColor.b = max(newColor.b, 0)

	return newColor

func healTowardsTarget(color: Color, targetColor: Color, rate: float) -> Color:
	var newColor = color
	newColor.a = 1.0

	if newColor.r < targetColor.r:
		newColor.r += rate
		newColor.r = max(newColor.r, 0)
	
	if newColor.g < targetColor.g:
		newColor.g += rate
		newColor.g = max(newColor.g, 0)

	if newColor.b < targetColor.b:
		newColor.b += rate
		newColor.b = max(newColor.b, 0)

	return newColor
