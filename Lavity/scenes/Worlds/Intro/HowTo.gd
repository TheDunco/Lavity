extends Node2D

const moteScene = preload("res://scenes/Objects/Mote.tscn")
@onready var player: Player = $Player
@onready var playerLight = player.playerLight
@onready var background: Sprite2D = $Background

var howToTextIndex := -1
const howToText: Array[String] = [
	"\n\n\n\n\n[center]Welcome, [pulse]Cosmo[/pulse], to the synesthetic world of [wave]Lavity[/wave][/center]",
	"\n\n\n\n\n[center]The laws of physics are altered here: light gives off gravitational force, and color blends with sound.[/center]",
	"\n\n\n\n\n[center]Light is the key to your survival as a moth, and you've adapted to use it in in unique ways to help you stay alive.[/center]",
	"\n\n\n\n\n[center]Different colors give you different effects...[/center]",
	"\n\n\n\n\n[center][color=yellow]Yellow determines how far you can see[/color][/center]", # 4
	"\n\n\n\n\n[center][color=orange]Orange determines the size of your light[/color][/center]", # 5
	"\n\n\n\n\n[center][color=green]Green determines your speed[/color][/center]", # 6
	"\n\n\n\n\n[center][color=rebecca_purple]Bluish purple (and similar) allows you to press [code]F[/code] to temporarily turn off your light for stealth purposes or to conserve light[/color][/center]", # 7
	"\n\n\n\n\n[center][color=pink]Pink determines the rate at which you lose color[/color][/center]", # 8
	"\n\n\n\n\n[center]You can use [code]SCROLL WHEEL[/code] to shift the hue of your color manually...[/center]",
	"\n\n\n\n\n[center]White gives you the benefits of all colors, but be aware that hue shifting isn't as effective[/center]", # 10
	"\n\n\n\n\n[center]However, there are two ways to bleed color faster so you can gain more of a specific color[/center]", # 11
	"\n\n\n\n\n[center][code]RIGHT CLICK[/code] to spend some color to repulse away objects and enemies. Hold to bleed even more color.[/center]", # 12
	"\n\n\n\n\n[center][code]LEFT CLICK[/code] to eject some of your color into a [rainbow freq=0.2 sat=0.5]mote[/rainbow][/center]", # 13
	"\n\n\n\n\n[center]Colliding with other forms of light will allow you to absorb some of their color[/center]", # 14
	"\n\n\n\n\n[center]Going too long without color means you'll die[/center]", # 15
	# TODO: Continue by switching to another scene to introduce the enemies. "But you're not alone..."
]

func tweenToColor(color: Color):
	var playerColorTween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	playerColorTween.tween_property(playerLight, "color", color, 2.0)

func instantiateMote(color: Color) -> void:
	var mote = moteScene.instantiate()
	add_child(mote)
	mote.global_position = player.global_position
	mote.decayRate = 0.0
	mote.changeColor(color)
	mote.pop.play()

func nextHowToText():
	howToTextIndex += 1
	if howToTextIndex < howToText.size() and howToTextIndex >= 0:
		SignalBus.displayHeroText.emit(howToText[howToTextIndex])
	else:
		howToTextIndex = howToText.size() - 1

	match howToTextIndex:
		4: tweenToColor(ColorUtils.YELLOW)
		5: tweenToColor(ColorUtils.ORANGE)
		6: tweenToColor(ColorUtils.GREEN)
		7: tweenToColor(ColorUtils.PURPLE)
		8: tweenToColor(ColorUtils.PINK)
		10, 11, 12, 13: tweenToColor(Color.WHITE)
		14:
			tweenToColor(Color.DIM_GRAY)
			for color in ColorUtils.colors:
				instantiateMote(color)
	

func _ready() -> void:
	nextHowToText()
	SignalBus.heroTextDoneDisplaying.connect(nextHowToText)

func _process(_delta: float) -> void:
	background.global_position = player.global_position

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("skip"):
		nextHowToText()
	if event.is_action_released("skip_back"):
		howToTextIndex -= 2
		nextHowToText()
