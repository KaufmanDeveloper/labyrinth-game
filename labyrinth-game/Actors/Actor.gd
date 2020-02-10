extends Node

onready var animationPlayer = $AnimationPlayer
onready var actorSprite = $ActorSprite

var talking = false
var actor = actorSprite

signal actor_loaded

func _process(delta):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("actor_loaded")
	if talking:
		animationPlayer.play("Talking")
	else:
		animationPlayer.stop(true) # Stop and reset animation
