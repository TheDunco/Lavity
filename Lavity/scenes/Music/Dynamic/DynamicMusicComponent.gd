extends AudioStreamPlayer
class_name DynamicMusicComponent

@export var ColorTracks: Array[AudioStreamPlayer] = []

func loop(song: AudioStreamPlayer):
	song.stop()
	song.play()
	
	

func _ready():
	for i in range(ColorTracks.size()):
		ColorTracks[i].volume_db = -80
		ColorTracks[i].connect("finished", func(): loop(ColorTracks[i]))

func enable():
	for i in range(ColorTracks.size()):
		ColorTracks[i].play()

func disable():
	for i in range(ColorTracks.size()):
		ColorTracks[i].stop()

func scoreToVolume(score: float, trackIndex: int):
	ColorTracks[trackIndex].volume_db = remap(score, 0.0, 1.0, -80, 0)

# Synisthesia
func setDynamicTrackVolume(color: Color):
	for i in range(ColorTracks.size()):
		scoreToVolume(COLOR_UTILS.scoreColorLikeness(color, COLOR_UTILS.colorsArray[i]), i)
