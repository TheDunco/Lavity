extends AudioStreamPlayer

func autoplay():
	stream_paused = false
	play()

func _on_finished():
	autoplay()
