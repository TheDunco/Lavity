extends AudioStreamPlayer
class_name DynamicMusicComponent

const MIN_VOLUME = -80

@export var ColorTracks: Array[AudioStreamPlayer] = []
@onready var swell: AudioStreamPlayer = $Swell

func loop(song: AudioStreamPlayer):
	song.stop()
	song.play()
	
func _ready():
	for i in range(ColorTracks.size()):
		ColorTracks[i].volume_db = MIN_VOLUME
		ColorTracks[i].connect("finished", func(): loop(ColorTracks[i]))

func enable():
	for i in range(ColorTracks.size()):
		ColorTracks[i].play()

func disable():
	for i in range(ColorTracks.size()):
		ColorTracks[i].stop()

func scoreToVolume(score: float, trackIndex: int):
	ColorTracks[trackIndex].volume_db = remap(score, 0.0, 2.0, MIN_VOLUME , 0)

# Synisthesia
func setDynamicTrackVolume(color: Color):
	for i in range(ColorTracks.size()):
		var whiteScore = ColorUtils.scoreColorLikeness(color, Color.WHITE)
		scoreToVolume(whiteScore + ColorUtils.scoreColorLikeness(color, ColorUtils.colorsArray[i]), i)	
