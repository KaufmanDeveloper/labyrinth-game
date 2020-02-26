extends Button

onready var animationPlayer = $AnimationPlayer
onready var hoverSound = $HoverSound
onready var pressedSound = $PressedSound

signal click_finished

func _ready():
	self.set_pivot_offset(self.get_size() / 2)

func _on_CustomButton_pressed():
	animationPlayer.play("Pressed")
	pressedSound.play()
	yield(animationPlayer, "animation_finished")
	emit_signal("click_finished")


func _on_CustomButton_mouse_entered():
	hoverSound.play()
