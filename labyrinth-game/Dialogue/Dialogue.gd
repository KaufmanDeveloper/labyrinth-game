extends Node

onready var MusicPlayer = load("res://Music/MusicPlayer.tscn")

export (String, FILE, "*.json") var dialogue_file_path : String
export (AudioStream) var track

func _ready():
	var musicPlayer = MusicPlayer.instance()
	add_child(musicPlayer)
	musicPlayer.set_stream(track)
	musicPlayer.play(0)
	interact()

func interact() -> void:
	var dialogue : Dictionary = load_dialogue(dialogue_file_path)
	print(dialogue)
	
func load_dialogue(file_path) -> Dictionary:
	# Parses a JSON file and returns it as a dictionary
	var file = File.new()
	assert(file.file_exists(file_path))
	
	file.open(file_path, file.READ)
	var dialogue = parse_json(file.get_as_text()) # Parse json into dictionary
	assert(dialogue.size() > 0) # Ensure dialogue has length
	return dialogue
