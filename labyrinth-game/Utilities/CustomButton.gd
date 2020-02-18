extends Button

onready var animationPlayer = $AnimationPlayer
onready var hoverSound = $HoverSound
onready var pressedSound = $PressedSound

func _ready():
	self.set_pivot_offset(self.get_size() / 2)
	print(self.get_pivot_offset())

func _on_CustomButton_pressed():
	animationPlayer.play("Pressed")
	pressedSound.play()


func _on_CustomButton_mouse_entered():
	hoverSound.play()
