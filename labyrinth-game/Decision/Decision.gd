extends Node

onready var background = $Background
onready var currentActor = $CurrentActor
onready var firstChoiceButton = $UI/Panel/GridContainer/FirstChoiceButton
onready var secondChoiceButton = $UI/Panel/GridContainer/SecondChoiceButton

export (Texture) var backgroundTexture : Texture
export (Texture) var currentActorTexture : Texture
export (String) var firstChoice : String
export (String) var secondChoice : String

func _ready():
	background.set_texture(backgroundTexture)
	currentActor.set_texture(currentActorTexture)
	firstChoiceButton.set_text(firstChoice)
	secondChoiceButton.set_text(secondChoice)
