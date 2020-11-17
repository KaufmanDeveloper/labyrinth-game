extends Node

export(Array, PackedScene) var elements = []

onready var MusicPlayer = load("res://Music/MusicPlayer.tscn")
const DecisionTree = preload("res://Globals/DecisionTree.tres")
const Fades = preload("res://Utilities/Transitions/Fades.tscn")

var fadesAnimationPlayer = null
var currentElementInstance = null
var currentBattleInstance = null
var currentDialogueIndex = null
var musicPlayer = null

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	musicPlayer = MusicPlayer.instance()
	add_child(musicPlayer)
	
	for element in elements:
		var elementInstance = element.instance()
		add_child(elementInstance)
		currentElementInstance = elementInstance
		
		if fadesAnimationPlayer == null:
			var fades = Fades.instance()
			add_child(fades)
			fadesAnimationPlayer = fades.get_node("AnimationPlayer")
			fadesAnimationPlayer.play("FadeIn")
			yield(fadesAnimationPlayer, "animation_finished")
			remove_child(fades)
		
		var containsLoadBattleSignal = false
		var containsLoadMusicSignal = false
		for currentSignal in elementInstance.get_signal_list():
			if(currentSignal["name"] == "load_battle"):
				containsLoadBattleSignal = true
			if (currentSignal["name"] == "load_music"):
				containsLoadMusicSignal = true
		
		if containsLoadBattleSignal:
			elementInstance.connect("load_battle", self, "on_battle_loaded")
		if containsLoadMusicSignal:
			elementInstance.connect("load_music", self, "on_music_loaded")
		
		
		yield(self, "finished")
		containsLoadBattleSignal = false
		
		if element == elements[elements.size() -1]: # Fade if last element
			var fades = Fades.instance()
			add_child(fades)
			fadesAnimationPlayer = fades.get_node("AnimationPlayer")
			fadesAnimationPlayer.play("FadeOut")
			yield(fadesAnimationPlayer, "animation_finished")
		
		
		remove_child(elementInstance)
	
	emit_signal("finished")

func remove_and_save_position(currentElement):
	if currentElement.type == "Dialogue":
		currentDialogueIndex = currentElement.currentIndex
	
	remove_child(currentElement)

func add_back_and_continue_dialogue():
	var fades = Fades.instance()
	add_child(fades)
	var fadesAnimationPlayer = fades.get_node("AnimationPlayer")
	fadesAnimationPlayer.play("FadeOut")
	yield(fadesAnimationPlayer, "animation_finished")
	
	remove_child(currentBattleInstance)
	
	currentElementInstance.initialIndex = currentDialogueIndex
	add_child(currentElementInstance)
	move_child(currentElementInstance, 0)
	currentElementInstance.emit_signal('battle_succeeded')
	
	fadesAnimationPlayer.play("FadeIn")
	yield(fadesAnimationPlayer, "animation_finished")
	remove_child(fades)

func on_battle_loaded(battleName):
	var CurrentBattle = load("res://Battle/Battle/" + battleName + "/" + battleName + ".tscn")
	
	var fades = Fades.instance()
	add_child(fades)
	var fadesAnimationPlayer = fades.get_node("AnimationPlayer")
	fadesAnimationPlayer.play("FadeOut")
	yield(fadesAnimationPlayer, "animation_finished")
	
	remove_and_save_position(currentElementInstance)
	currentBattleInstance = CurrentBattle.instance()
	add_child(currentBattleInstance)
	move_child(currentBattleInstance, 0) # Move to higher position than animation so animation is visible
	
	fadesAnimationPlayer.play("FadeIn")
	yield(fadesAnimationPlayer, "animation_finished")
	remove_child(fades)
	
	currentBattleInstance.connect("success", self, "on_battle_success")

func on_battle_success():
	if currentElementInstance.type == "Dialogue":
		add_back_and_continue_dialogue()

func on_music_loaded(trackName):
	var CurrentTrackAudioFile = load("res://Music/Exported/" + trackName + ".ogg")
	
	musicPlayer.crossfade_to(CurrentTrackAudioFile)
