extends Node

# Make sure that node is loaded when setting variable
onready var hpLabel = $Enemy/HPLabel

func _on_SwordButton_pressed():
	hpLabel.text = "15hp"
