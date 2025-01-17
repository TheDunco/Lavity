extends AudioStreamPlayer
class_name SfxComponent

@onready var drain = $Drain
@onready var imminentDeath = $ImminentDeath
@onready var buttonHover = $ButtonHover
@onready var buttonClick = $ButtonClick
@onready var tonalClick = $TonalClick
@onready var repulse = $Repulse
@onready var pop = $Pop

func playButtonHover():
	buttonHover.pitch_scale = randf_range(1.1, 1.3)
	buttonHover.play()

func playButtonClick():
	buttonClick.pitch_scale = randf_range(1.1, 1.3)
	buttonClick.play()
	
func playTonalClick(pitchScale: float):
	tonalClick.pitch_scale = pitchScale
	tonalClick.play()
	
func playRepulse():
	repulse.play()
	
func playImminentDeath():
	imminentDeath.volume_db = 0
	imminentDeath.play()
func stopImminentDeath():
	imminentDeath.stop()

func playDrain(pitch: float):
	drain.pitch_scale = pitch
	if not drain.is_playing():
		drain.play()
func stopDrain():
	drain.stop()
	
func playPop(pitch = 1.0):
	pop.pitch_scale = pitch
	pop.play()
