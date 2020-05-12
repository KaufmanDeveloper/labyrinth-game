extends Control

signal finished(succeeded)

export (int) var speed

onready var sliderArea = $SliderArea

var success = false
var finished = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	var currentPosition = sliderArea.get_position()
	# Before moving, check if input detected and handle accordingly
	
	# Move Slider
	if !finished:
		move_slider(currentPosition)
	else:
#		play_animation()
#		yield(play_animation(), "completed")
		emit_signal("finished", success)
	
	if Input.is_action_just_pressed("ui_accept"):
		handle_click(currentPosition)

# Handle click action, check if succeeded
func handle_click(position):
	print('clicked')
#	if (sliderIsInsideWinBox):
#		success = true
	
#	finished = true

# Handle movement of slider
func move_slider(position):
	var moveAmount = speed * .7
	position.x += moveAmount
	
	sliderArea.set_position(position)
