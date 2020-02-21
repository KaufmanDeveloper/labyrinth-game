extends Node

export(Array, PackedScene) var elements = []

const DecisionTree = preload("res://Globals/DecisionTree.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	for element in elements:
		var elementInstance = element.instance()
		add_child(elementInstance)
		yield(elementInstance, "finished")
		remove_child(elementInstance)
