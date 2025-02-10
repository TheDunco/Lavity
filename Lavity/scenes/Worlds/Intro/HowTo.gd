extends Node2D

const moteScene = preload("res://scenes/Objects/Mote.tscn")
@onready var player: Player = $Player
@onready var playerLight = player.playerLight
@onready var background: Sprite2D = $Background

var howToTextIndex := -1
const howToText: Array[String] = [
	"\n\n\n\n\n[center]Welcome, [pulse]Cosmo[/pulse], to the synesthetic world of [wave]Lavity[/wave][/center]",
	"\n\n\n\n\n[center]The laws of physics are altered here: light gives off gravitational force, and color blends with sound. Use [code]W A S D[/code] to move around[/center]",
	"\n\n\n\n\n[center]Light is the key to your survival as a moth, and you've adapted to use it in in unique ways to help you stay alive.[/center]",
	"\n\n\n\n\n[center]Different colors give you different effects...[/center]",
	"\n\n\n\n\n[center][color=yellow]Yellow determines how far you can see[/color][/center]", # 4
	"\n\n\n\n\n[center][color=orange]Orange determines the size of your light[/color][/center]", # 5
	"\n\n\n\n\n[center][color=green]Green determines your speed[/color][/center]", # 6
	"\n\n\n\n\n[center][color=rebecca_purple]Bluish purple (and similar) allows you to press [code]F[/code] to temporarily turn off your light for stealth purposes or to conserve light[/color][/center]", # 7
	"\n\n\n\n\n[center][color=pink]Pink reduces the rate at which you lose color[/color][/center]", # 8
	"\n\n\n\n\n[center]You can use [code]SCROLL WHEEL[/code] to shift the hue of your color manually...[/center]", # 9
	"\n\n\n\n\n[center]White gives you the benefits of all colors, but white does not have hue, so hue shifting won't work[/center]", # 10
	"\n\n\n\n\n[center]However, there are two ways to bleed color faster so you can gain more of a specific color[/center]", # 11
	"\n\n\n\n\n[center][code]RIGHT CLICK[/code] to spend some color to repulse away objects and enemies. Hold to bleed even more color.[/center]", # 12
	"\n\n\n\n\n[center][code]LEFT CLICK[/code] to eject some of your color into a [rainbow freq=0.2 sat=0.5]mote[/rainbow][/center]", # 13
	"\n\n\n\n\n[center]Colliding with other forms of light will allow you to absorb some of their color[/center]", # 14
	"\n\n\n\n\n[center]Going too long without light means you'll die: this also applies to other creatures, like the Spotted Lanternfly[/center]", # 15
	"\n\n\n\n\n[center]Head to the [wave]Maze[/wave] mode to meet some of them, but be sure they don't steal all of your light![/center]", # 16
	"\n\n\n\n\n[center][/center]" # 17
]

func createColorTween() -> Tween:
	return create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func tweenToColor(color: Color, duration: float = 2.0):
	var playerColorTween := createColorTween()
	playerColorTween.tween_property(playerLight, "color", color, duration)

func instantiateMote(color: Color) -> void:
	var mote = moteScene.instantiate()
	add_child(mote)
	mote.global_position = player.global_position
	mote.decayRate = 0.0
	mote.changeColor(color)
	mote.pop.play()

const TWEEN_DURATION = 12.0 / 10.0 # 12 colors / 10 seconds
func startColorTweenChain(index: int = 0) -> void:
	if index >= ColorUtils.colorsArray.size() - 2:
		return
	var tween := createColorTween()
	tween.finished.connect(func(): startColorTweenChain(index + 1))
	tween.tween_property(playerLight, "color", ColorUtils.colorsArray[index + 1], TWEEN_DURATION)
	if index == 0:
		tween.tween_property(playerLight, "color", ColorUtils.colorsArray[0], TWEEN_DURATION)

func nextHowToText():
	howToTextIndex += 1
	if howToTextIndex < howToText.size() and howToTextIndex >= 0:
		SignalBus.displayHeroText.emit(howToText[howToTextIndex])
	else:
		howToTextIndex = howToText.size() - 1

	match howToTextIndex:
		0, 1, 2: tweenToColor(ColorUtils.PINK)
		3: startColorTweenChain()
		4: tweenToColor(ColorUtils.YELLOW)
		5: tweenToColor(ColorUtils.ORANGE)
		6: tweenToColor(ColorUtils.GREEN)
		7: tweenToColor(ColorUtils.PURPLE)
		8: tweenToColor(ColorUtils.PINK)
		10, 11, 12: tweenToColor(Color.WHITE)
		13: startColorTweenChain()
		14:
			tweenToColor(Color.DIM_GRAY)
			for color in ColorUtils.colors:
				instantiateMote(color)
		15: tweenToColor(Color.DIM_GRAY)
	

func _ready() -> void:
	nextHowToText()
	SignalBus.heroTextDoneDisplaying.connect(nextHowToText)
	background.modulate = Color.BLACK
	var backgroundFadeIn = create_tween().set_trans(Tween.TRANS_LINEAR)
	backgroundFadeIn.tween_property(background, "modulate", Color.WHITE, 6.0)

func _process(_delta: float) -> void:
	background.global_position = player.global_position
