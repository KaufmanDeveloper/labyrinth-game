extends Node

onready var background = $Background
onready var currentActor = $CurrentActor

export (Texture) var backgroundTexture : Texture
export (Texture) var currentActorTexture : Texture

func _ready():
	background.set_texture(backgroundTexture)
	currentActor.set_texture(currentActorTexture)
