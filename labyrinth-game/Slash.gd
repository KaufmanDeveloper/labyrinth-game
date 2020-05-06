extends Node2D

onready var bashSound = $BashSound

func _ready():
	bashSound.play()

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
