extends AudioStreamPlayer
class_name DynamicMusicComponent

const MIN_VOLUME = -80

@export var ColorTracks: Array[AudioStreamPlayer] = []
@onready var swell: AudioStreamPlayer = $Swell

@onready var numDynamicTracks := ColorTracks.size()

func loop(song: AudioStreamPlayer):
	song.stop()
	song.play()
	
func _ready():
	for i in range(numDynamicTracks):
		ColorTracks[i].volume_db = MIN_VOLUME
		ColorTracks[i].connect("finished", func(): loop(ColorTracks[i]))

func _playAllDynamicTracks():
	for i in range(numDynamicTracks):
		ColorTracks[i].play()

func enable():
	swell.connect("finished", _playAllDynamicTracks)
	swell.play()

func disable():
	for i in range(numDynamicTracks):
		ColorTracks[i].stop()

func scoreToVolume(score: float, trackIndex: int):
	ColorTracks[trackIndex].volume_db = remap(score, 0.0, 2.0, MIN_VOLUME , 0)

# Synisthesia
func setDynamicTrackVolume(color: Color):
	for i in range(numDynamicTracks):
		var whiteScore = ColorUtils.scoreColorLikeness(color, Color.WHITE)
		scoreToVolume(whiteScore + ColorUtils.scoreColorLikeness(color, ColorUtils.colorsArray[i]), i)
