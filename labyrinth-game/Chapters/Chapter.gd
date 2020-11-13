extends Node

export(Array, PackedScene) var elements = []
export (AudioStream) var track

onready var MusicPlayer = load("res://Music/MusicPlayer.tscn")
const DecisionTree = preload("res://Globals/DecisionTree.tres")
const Fades = preload("res://Utilities/Transitions/Fades.tscn")

var fadesAnimationPlayer = null
var currentElementInstance = null
var currentBattleInstance = null
var currentDialogueIndex = null

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	var musicPlayer = MusicPlayer.instance()
	add_child(musicPlayer)
	musicPlayer.set_stream(track)
	musicPlayer.play(0)
	
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
		for currentSignal in elementInstance.get_signal_list():
			if(currentSignal["name"] == "load_battle"):
				containsLoadBattleSignal = true
		
		if containsLoadBattleSignal:
			elementInstance.connect("load_battle", self, "on_battle_loaded")
		
		
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
