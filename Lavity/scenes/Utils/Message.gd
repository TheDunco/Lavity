extends Node2D

@onready var heroText: RichTextLabel = $CanvasLayer/MessageBox/CenterContainer/HeroText

func tweenHeroTextOpacity(outOnly := false) -> void:
	var heroTextOpacityTween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	if not outOnly:
		heroTextOpacityTween.tween_property(heroText, "modulate:a", 1.0, 1.0)
	heroTextOpacityTween.tween_property(heroText, "modulate:a", 0.0, GlobalConfig.HERO_TEXT_TWEEN_TIME)
	heroTextOpacityTween.finished.connect(func(): SignalBus.heroTextDoneDisplaying.emit())

func displayHeroText(text: String) -> void:
	GameFlow.heroText = text
	heroText.text = text
	tweenHeroTextOpacity()

func displayLastText() -> void:
	tweenHeroTextOpacity()

func _ready() -> void:
	heroText.text = GameFlow.heroText
	SignalBus.displayHeroText.connect(displayHeroText)
	tweenHeroTextOpacity(true)
