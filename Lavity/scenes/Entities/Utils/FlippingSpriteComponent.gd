extends Node

@export var spriteBasePosition := 0
@export var isHandlingVelocityInput := false
@export var entity: CharacterBody2D  = null

var flippingSprite: AnimatedSprite2D = null

func _ready():
	flippingSprite = get_parent()

func _process(_delta):
	if isHandlingVelocityInput:
		flippingSprite.speed_scale = $"../../VelocityComponent".getAnimationSpeed(entity.velocity)
	elif flippingSprite.speed_scale < 0:
		flippingSprite.speed_scale -= 1
	else:
		flippingSprite.speed_scale = 0
		var currentFrame = flippingSprite.frame
		if currentFrame != spriteBasePosition:
			if currentFrame > spriteBasePosition:
				flippingSprite.frame -= 1
			else:
				flippingSprite.frame += 1
