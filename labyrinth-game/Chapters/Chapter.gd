extends Node

onready var animationPlayer = $AnimationPlayer
onready var colorRect = $ColorRect

export(Array, PackedScene) var elements = []

const DecisionTree = preload("res://Globals/DecisionTree.tres")
const Fades = preload("res://Utilities/Transitions/Fades.tscn")

var fadesAnimationPlayer = null

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for element in elements:
		var elementInstance = element.instance()
		add_child(elementInstance)
		
		if fadesAnimationPlayer == null:
			var fades = Fades.instance()
			add_child(fades)
			fadesAnimationPlayer = fades.get_node("AnimationPlayer")
			fadesAnimationPlayer.play("FadeIn")
			yield(fadesAnimationPlayer, "animation_finished")
			remove_child(fades)
		
		
		yield(elementInstance, "finished")
		
		if element == elements[elements.size() -1]: # Fade if last element
			var fades = Fades.instance()
			add_child(fades)
			fadesAnimationPlayer = fades.get_node("AnimationPlayer")
			fadesAnimationPlayer.play("FadeOut")
			yield(fadesAnimationPlayer, "animation_finished")
		
		
		remove_child(elementInstance)
	
	emit_signal("finished")
