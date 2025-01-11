extends AudioStreamPlayer
class_name SfxComponent

@onready var drain = $Drain
@onready var imminentDeath = $ImminentDeath

func playButtonHover():
	print("button hover sound play")
	$ButtonHover.pitch_scale = randf_range(1.1, 1.3)
	$ButtonHover.play()

func playButtonClick():
	$ButtonClick.pitch_scale = randf_range(1.1, 1.3)
	$ButtonClick.play()
	
func playTonalClick(pitchScale: float):
	$TonalClick.pitch_scale = pitchScale
	$TonalClick.play()
	
func playRepulse():
	$Repulse.play()
	
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
