extends Node

export(Array, PackedScene) var elements = []
export (AudioStream) var track

onready var MusicPlayer = load("res://Music/MusicPlayer.tscn")
const DecisionTree = preload("res://Globals/DecisionTree.tres")
const Fades = preload("res://Utilities/Transitions/Fades.tscn")

var fadesAnimationPlayer = null
var currentElementInstance = null

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
		
#		print(elementInstance.get_signal_list())
#		print(elementInstance.get_signal_list()[0]["name"] == "load_battle")
		var containsLoadBattleSignal = false
		for currentSignal in elementInstance.get_signal_list():
			if(currentSignal["name"] == "load_battle"):
				containsLoadBattleSignal = true
		
		if containsLoadBattleSignal:
			elementInstance.connect("load_battle", self, "on_battle_loaded")
		
		yield(elementInstance, "finished")
		containsLoadBattleSignal = false
		
		if element == elements[elements.size() -1]: # Fade if last element
			var fades = Fades.instance()
			add_child(fades)
			fadesAnimationPlayer = fades.get_node("AnimationPlayer")
			fadesAnimationPlayer.play("FadeOut")
			yield(fadesAnimationPlayer, "animation_finished")
		
		
		remove_child(elementInstance)
	
	emit_signal("finished")

func on_battle_loaded(battleName):
	var CurrentBattle = load("res://Battle/Battle/" + battleName + "/" + battleName + ".tscn")
	
	# Need to fade out, initiate battle, await success. If success, fade in and return
	var fades = Fades.instance()
	add_child(fades)
	var fadesAnimationPlayer = fades.get_node("AnimationPlayer")
	fadesAnimationPlayer.play("FadeOut")
	yield(fadesAnimationPlayer, "animation_finished")
	
	remove_child(currentElementInstance)
	var currentBattleInstance = CurrentBattle.instance()
	self.add_child(currentBattleInstance)
	
	fadesAnimationPlayer.play("FadeIn")
	yield(fadesAnimationPlayer, "animation_finished")
	remove_child(fades)
	
	currentBattleInstance.connect("success", self, "on_battle_success")
