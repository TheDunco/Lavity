extends AudioStreamPlayer
class_name SfxComponent

func playButtonHover():
	print("button hover sound play")
	$ButtonClick.pitch_scale = randf_range(1.1, 1.3)
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
	$ImminentDeath.play()
