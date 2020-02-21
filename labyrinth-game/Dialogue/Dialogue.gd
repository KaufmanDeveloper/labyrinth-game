extends Node

onready var MusicPlayer = load("res://Music/MusicPlayer.tscn")
onready var actors = []

onready var nameText = $UI/DialoguePanel/NamePanel/NameText
onready var dialogueText = $UI/DialoguePanel/DialogueText
onready var textSound = $TextSound
onready var textInSound = $TextIn
onready var textOutSound = $TextOut
onready var animationPlayer = $AnimationPlayer
onready var spriteFadesAnimationPlayer = $SpriteFadesAnimationPlayer
onready var currentActor = $CurrentActor

export (String, FILE, "*.json") var dialogue_file_path : String
export (AudioStream) var track

signal proceed_dialogue
signal finished

var textTimer = 0
var textRevealed = 0
var dialogueIsRevealing = true
var nameIsChecked = false
var isInitialRender = true
var currentActorName = ""

func _ready():
	var musicPlayer = MusicPlayer.instance()
	add_child(musicPlayer)
	musicPlayer.set_stream(track)
	musicPlayer.play(0)
	interact()

func _process(delta):
	if nameIsChecked:
		type_text()


func interact() -> void:
	var dialogue : Dictionary = load_dialogue(dialogue_file_path)
	load_actors(dialogue)
	
	for index in dialogue:
		var currentDialogue = dialogue[index]
		check_actor(currentDialogue.name)
		print_text(currentDialogue.text)
		yield(self, "proceed_dialogue")
	
	emit_signal("finished")
	
func load_dialogue(file_path) -> Dictionary:
	# Parses a JSON file and returns it as a dictionary
	var file = File.new()
	assert(file.file_exists(file_path))
	
	file.open(file_path, file.READ)
	var dialogue = parse_json(file.get_as_text()) # Parse json into dictionary
	assert(dialogue.size() > 0) # Ensure dialogue has length
	return dialogue

func print_text(text):
	dialogueText.set_visible_characters(textRevealed)
	dialogueText.set_text(text)

func check_actor(name):
	if nameText.get_text() == "Jem" and name == "Player" or (nameText.get_text() == name):
		return
	
	if currentActorName != name:
		currentActorName = name
		if name != "Player" and name != currentActor.get_actorName():
			change_actor(name)
	
	nameText.set_text("")
	nameIsChecked = false
	
	if not isInitialRender:
		animationPlayer.play("NamePanelOut")
		yield(animationPlayer, "animation_finished")
		textOutSound.play()
		animationPlayer.play("DialogueBoxOut")
		yield(animationPlayer, "animation_finished")
		yield(get_tree().create_timer(0.4), "timeout")
	
	isInitialRender = false
	textInSound.play()
	animationPlayer.play("DialogueBoxIn")
	yield(animationPlayer, "animation_finished")
	animationPlayer.play("NamePanelIn")
	yield(animationPlayer, "animation_finished")
	
	# Will need to take array of actors and compare them to name field
	if name == "Player":
		nameText.set_text("Jem")
	else:
		nameText.set_text(name)
	
	nameIsChecked = true

func reset_text_timers():
	textTimer = 0
	textRevealed = 0
	dialogueIsRevealing = true

func type_text():
	if dialogueIsRevealing:
		if currentActor and (not animationPlayer.current_animation == "Talking") and currentActorName != "Player":
			animationPlayer.play("Talking")
		elif animationPlayer.current_animation == "Talking" and currentActorName == "Player":
			animationPlayer.stop()
		
		if Input.is_action_just_pressed("ui_accept"):
			textRevealed = dialogueText.get_text().length()
		textTimer += 1
		if textTimer >= 4:
			textTimer = 0
			if textRevealed < dialogueText.get_text().length():
				if dialogueText.get_text().substr(textRevealed, 1) != " ":
					textSound.play(0)
				textRevealed += 1
		if textRevealed >= dialogueText.get_text().length():
			dialogueIsRevealing = false
		dialogueText.set_visible_characters(textRevealed)
	else:
		if animationPlayer.current_animation == "Talking":
			animationPlayer.stop()
			currentActor.set_frame(0)
		
		if Input.is_action_just_pressed("ui_accept") and not dialogueIsRevealing:
			reset_text_timers()
			emit_signal("proceed_dialogue")

func load_actors(dialogue):
	var names = []
	for index in dialogue:
		var currentDialogue = dialogue[index]
		if(currentDialogue.name != "Player" and names.find(currentDialogue.name) == -1):
			names.push_back(currentDialogue.name)
			var CurrentActor = load("res://Actors/" + currentDialogue.name + ".tscn")
			var currentActor = CurrentActor.instance()
			actors.push_back(currentActor)
	
	# Set first actor to talk as displayed actor
	currentActor.set_texture(actors[0].get_node("ActorSprite").get_texture())
	currentActor.set_actorName(actors[0].actorName)

func change_actor(name):
	for actor in actors:
		if name == actor.actorName:
			spriteFadesAnimationPlayer.play("FadeOutActor")
			yield(spriteFadesAnimationPlayer, "animation_finished")
			currentActor.set_texture(actor.get_node("ActorSprite").get_texture())
			yield(get_tree().create_timer(0.4), "timeout")
			spriteFadesAnimationPlayer.play("FadeInActor")
			yield(spriteFadesAnimationPlayer, "animation_finished")
			currentActor.set_actorName(name)
			return
