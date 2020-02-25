extends Node

onready var background = $Background
onready var currentActor = $CurrentActor
onready var firstChoiceButton = $UI/Panel/GridContainer/FirstChoiceButton
onready var secondChoiceButton = $UI/Panel/GridContainer/SecondChoiceButton
onready var choiceMadeSound = $ChoiceMadeSound

export (Texture) var backgroundTexture : Texture
export (Texture) var currentActorTexture : Texture
export (String) var firstChoice : String
export (String) var secondChoice : String

var type = "decision"
var choiceMade setget set_choiceMade # Accessed by parent to understand choice made
signal finished

func _ready():
	background.set_texture(backgroundTexture)
	currentActor.set_texture(currentActorTexture)
	firstChoiceButton.set_text(firstChoice)
	secondChoiceButton.set_text(secondChoice)


func _on_FirstChoiceButton_pressed():
	choiceMade = firstChoiceButton.get_text()
	choiceMadeSound.play()
	yield(firstChoiceButton, "click_finished")
	hide_buttons()
	yield(get_tree().create_timer(1.0), "timeout")
	emit_signal("finished")

func _on_SecondChoiceButton_pressed():
	choiceMade = secondChoiceButton.get_text()
	choiceMadeSound.play()
	yield(secondChoiceButton, "click_finished")
	hide_buttons()
	yield(get_tree().create_timer(1.0), "timeout")
	emit_signal("finished")

func set_choiceMade(choice):
	choiceMade = choice

func hide_buttons():
	firstChoiceButton.hide()
	secondChoiceButton.hide()
