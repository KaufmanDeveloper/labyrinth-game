extends AudioStreamPlayer

onready var musicPlayer2 = $MusicPlayer2
onready var animationPlayer = $AnimationPlayer

func _ready():
	pass # Replace with function body.

# crossfades to a new audio stream
func crossfade_to(audio_stream: AudioStream) -> void:
	var musicPlayer1 = self
	
	# If both tracks are playing, we're calling the function in the middle of a fade.
	# We return early to avoid jumps in the sound.
	if musicPlayer1.playing and musicPlayer2.playing:
		return

	# The `playing` property of the stream players tells us which track is active. 
	# If it's track two, we fade to track one, and vice-versa.
	if musicPlayer2.playing:
		musicPlayer1.stream = audio_stream
		musicPlayer1.play()
		animationPlayer.play("FadeToTrack1")
	else:
		musicPlayer2.stream = audio_stream
		musicPlayer2.play()
		animationPlayer.play("FadeToTrack2")
