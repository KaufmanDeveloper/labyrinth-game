extends Node

onready var actors = []

onready var backgroundNode = $BackgroundNode
onready var namePanel = $UI/NamePanel
onready var nameText = $UI/NamePanel/NameText
onready var dialogueText = $UI/DialoguePanel/DialogueText
onready var textSound = $TextSound
onready var textInSound = $TextIn
onready var textOutSound = $TextOut
onready var animationPlayer = $AnimationPlayer
onready var spriteFadesAnimationPlayer = $SpriteFadesAnimationPlayer
onready var currentActor = $CurrentActor
onready var currentActor2 = $CurrentActor2

export (String, FILE, "*.json") var dialogue_file_path : String
export (PackedScene) var background = PackedScene.new()

const Fades = preload("res://Utilities/Transitions/Fades.tscn")
const type = "Dialogue"

signal proceed_dialogue
signal finished
signal load_battle
signal battle_succeeded
signal load_music
signal actor_faded_out

var textTimer = 0
var textRevealed = 0
var dialogueIsRevealing = true
var nameIsCheckedAndTypeText = false
var isInitialRender = true
var currentActorName = ""
var currentIndex = null
var initialIndex = null
var textStopped = false

func _ready():
	var backgroundInstance = background.instance()
	backgroundNode.add_child(backgroundInstance)
	interact()

func _process(_delta):
	if nameIsCheckedAndTypeText and !textStopped:
		type_text()


func interact() -> void:
	var dialogue : Dictionary = load_dialogue(dialogue_file_path)
	var previousIndex = null
	load_actors(dialogue)
	
	for index in dialogue.content:
		print(index)
#		if initialIndex and index <= initialIndex:
#			continue
		
		currentIndex = index
		var currentDialogue = index
		var previousName = null
		if (previousIndex):
			previousName = previousIndex.name 
		
		if (!'directive' in currentDialogue):
			check_actor(currentDialogue.name, previousName)
		
		if ("text" in currentDialogue):
			print_text(currentDialogue.text)
			yield(self, "proceed_dialogue")
			previousIndex = index
		
		if ('directive' in currentDialogue and 'name' in currentDialogue):
			if (currentDialogue.directive == 'fade_in'):
				fade_in_actor(currentDialogue.name)
			if (currentDialogue.directive == 'fade_out'):
				fade_out_actor(currentDialogue.name)
			if (currentDialogue.directive == 'battle'):
				textStopped = true
				initiate_battle(currentDialogue.name)
				yield(self, 'battle_succeeded')
				textStopped = false
			if (currentDialogue.directive == "play_song"):
				initiate_music(currentDialogue.name)
	
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

func check_actor(name, previousName):
	if nameText.get_text() == "Jem" and name == "Player" or (nameText.get_text() == name):
		return
	var shouldPlayNamePanelInAnimation = false
	var shouldPlayNamePanelOutAnimation = false
	
	if currentActorName != name:
		currentActorName = name
		if name != "Player" and name != currentActor.get_actorName():
			change_actor(previousName, name)
	
	nameIsCheckedAndTypeText = false
	
	if nameText.text != name:
		if name != 'Narrator':
			shouldPlayNamePanelInAnimation = true
		if namePanel.rect_size > Vector2(50, 50): # Check if need to play out animation
			shouldPlayNamePanelOutAnimation = true
		nameText.set_text("")
	
	if not isInitialRender:
		if shouldPlayNamePanelOutAnimation:
			animationPlayer.play("NamePanelOut")
			yield(animationPlayer, "animation_finished")
			textOutSound.play()
		if previousName and previousName != name:
			yield(get_tree().create_timer(0.4), "timeout")
	
	
	if (previousName and previousName != name) or isInitialRender:
		textInSound.play()

	if shouldPlayNamePanelInAnimation:
		animationPlayer.play("NamePanelIn")
		yield(animationPlayer, "animation_finished")
	
	
	
	# Will need to take array of actors and compare them to name field
	if name == "Player":
		nameText.set_text("Jem")
	elif name == "Narrator":
		nameText.set_text("")
	elif nameText.get_text() != name:
		nameText.set_text(name)
	
	if dialogueText:
		nameIsCheckedAndTypeText = true
	isInitialRender = false

func reset_text_timers():
	textTimer = 0
	textRevealed = 0
	dialogueIsRevealing = true

func type_text():
	if dialogueIsRevealing:
		if currentActor and currentActor2 and (not animationPlayer.current_animation == "Talking") and currentActorName != "Player":
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
			currentActor.visible = true;
			currentActor2.visible = false;
		
		if Input.is_action_just_pressed("ui_accept") and not dialogueIsRevealing:
			reset_text_timers()
			emit_signal("proceed_dialogue")

func load_actors(dialogue):
	var names = []
	for index in dialogue.content:
		var currentDialogue = index
		var isNotDirective = !'directive' in currentDialogue
		
		if(isNotDirective and currentDialogue.name != "Player" && currentDialogue.name != "Narrator" and names.find(currentDialogue.name) == -1):
			names.push_back(currentDialogue.name)
			var CurrentActor = load("res://Actors/" + currentDialogue.name + ".tscn")
			var currentActorInstance = CurrentActor.instance()
			actors.push_back(currentActorInstance)
	
	# Set first actor to talk as displayed actor
	if (actors.size()):
		currentActor.set_texture(actors[0].get_node("ActorSprite").get_texture())
		currentActor.set_actorName(actors[0].actorName)
		currentActor2.set_texture(actors[0].get_node("ActorSprite2").get_texture())
		currentActor2.set_actorName(actors[0].actorName)

func fade_in_actor(name):
	for actor in actors:
		if name == actor.actorName:
			currentActor.set_actorName(name)
			currentActor2.set_actorName(name)
			
			spriteFadesAnimationPlayer.play("FadeInActor")
			yield(spriteFadesAnimationPlayer, "animation_finished")
			
			return

func fade_out_actor(name, toName = false):
	for actor in actors:
		if name == actor.actorName:
			spriteFadesAnimationPlayer.play("FadeOutActor")
			yield(spriteFadesAnimationPlayer, "animation_finished")
			
			if (toName):
				currentActor.set_actorName(toName)
				currentActor2.set_actorName(toName)
			
			emit_signal("actor_faded_out")
			return

func change_actor(fromName, toName):
	for actor in actors:
		if toName == actor.actorName:
			
			fade_out_actor(fromName)
			yield(self, "actor_faded_out")
			
			currentActor.set_texture(actor.get_node("ActorSprite").get_texture())
			currentActor2.set_texture(actor.get_node("ActorSprite2").get_texture())
			yield(get_tree().create_timer(0.4), "timeout")
			
			fade_in_actor(toName)
			
			return

func initiate_battle(name):
	emit_signal("load_battle", name)

func initiate_music(name):
	emit_signal("load_music", name)
