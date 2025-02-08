extends Node2D

@onready var heroText: RichTextLabel = $CanvasLayer/MessageBox/CenterContainer/HeroText

func tweenOut() -> void:
	var heroTextOpacityOutTween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	heroTextOpacityOutTween.finished.connect(func(): SignalBus.heroTextDoneDisplaying.emit())
	heroTextOpacityOutTween.tween_property(heroText, "modulate:a", 0.0, GlobalConfig.HERO_TEXT_TWEEN_OUT_TIME)

func tweenHeroTextOpacity() -> void:
	heroText.modulate.a = 0.0
	var heroTextOpacityInTween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	heroTextOpacityInTween.finished.connect(tweenOut)
	heroTextOpacityInTween.tween_property(heroText, "modulate:a", 1.0, 1.0)

func displayHeroText(text: String) -> void:
	GameFlow.heroText = text
	heroText.text = text
	tweenHeroTextOpacity()

func displayLastText() -> void:
	tweenHeroTextOpacity()

func _ready() -> void:
	heroText.text = GameFlow.heroText
	SignalBus.displayHeroText.connect(displayHeroText)
