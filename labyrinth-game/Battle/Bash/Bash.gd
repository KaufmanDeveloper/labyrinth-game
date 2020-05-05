extends Node

signal finished(succeeded)

export (int) var speed

onready var frame = $Frame
onready var sliderArea = $SliderArea
onready var winBoxArea = $WinBoxArea # Be in bounds of this to win
onready var animationPlayer = $AnimationPlayer

var startPoint = 52
var frameWidth
var reversePoint = 164
var missedPoint = 44
var stopPoint = -164
var reversed = false

var success = false # Stop animation if success and emit a signal in _process
var finished = false

var sliderIsInsideWinBox = false

# Called when the node enters the scene tree for the first time.
func _ready():
	startPoint = sliderArea.get_position().x
	frameWidth = frame.texture.get_size().x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var currentPosition = sliderArea.get_position()
	# Before moving, check if input detected and handle accordingly
	
	# Move Slider
	if !finished:
		move_slider(currentPosition)
	else:
		play_animation()
		yield(play_animation(), "completed")
		emit_signal("finished", success)
	
	if Input.is_action_just_pressed("ui_accept"):
		handle_click(currentPosition)

# Handle movement of slider
func move_slider(position):
	var moveAmount = speed * .7
	var reverseThisTime = false
	
	if (reversePoint <= position.x + moveAmount) and !reversed:
		moveAmount = reversePoint - position.x
		reverseThisTime = true
	
	if reversed:
		if (stopPoint >= position.x - moveAmount):
			moveAmount = position.x - stopPoint
			finished = true
		
		position.x -= moveAmount
	else:
		position.x += moveAmount
	
	sliderArea.set_position(position)
	if reverseThisTime:
		reversed = true

# Handle click action, check if succeeded
func handle_click(position):
	if (sliderIsInsideWinBox):
		success = true
	
	finished = true

func play_animation():
	if (success):
		animationPlayer.play("Success")
	else:
		animationPlayer.play("Failure")
	
	yield(animationPlayer, "animation_finished")

func _on_WinBoxArea_area_entered(area):
	sliderIsInsideWinBox = true


func _on_WinBoxArea_area_exited(area):
	sliderIsInsideWinBox = false
