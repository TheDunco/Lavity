extends AudioStreamPlayer

signal songChanged(to: String)

@export var musicRotation: Array[AudioStreamPlayer] = []
var currentIndex = 0

# TODO: This isn't strongly tied with the musicRotation array configuration
# May have to aquire the music rotation dynamically instead of specifying through the inspector
enum SongEnum {
	LIGHT,
	A_NEW_COLOR,
	GRAVITY,
	A_MOTH_IN_LIGHT,
	LANTERN,
}

func playSong(song: SongEnum, startOver: bool = false):
	if currentIndex == song and not startOver:
		return
	musicRotation[currentIndex].stop()
	currentIndex = song
	musicRotation[currentIndex].play()
	emit_signal("songChanged", musicRotation[currentIndex].name)

func _ready():
	musicRotation[currentIndex].play()
	
func pause():
	musicRotation[currentIndex].stop()

func resume():
	musicRotation[currentIndex].play()

func next():
	musicRotation[currentIndex].stop()
	currentIndex += 1
	if currentIndex >= musicRotation.size():
		currentIndex = 0
	musicRotation[currentIndex].play()
	emit_signal("songChanged", musicRotation[currentIndex].name)

func _on_light_finished():
	next()

func _on_a_new_color_finished():
	next()

func _on_gravity_finished():
	next()

func _on_next_song_pressed():
	next()

func _on_a_moth_in_light_finished():
	next()
	
func _on_lantern_finished() -> void:
	next()

func _input(event):
	if event.is_action_pressed("next_song"):
		next()
