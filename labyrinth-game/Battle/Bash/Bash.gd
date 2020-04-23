extends Node

export (int) var speed

onready var frame = $Frame
onready var slider = $Slider
onready var winBox = $WinBox # Be in bounds of this to win

var startPoint = 52
var frameWidth
var reversePoint = 334
var missedPoint = 44
var stopPoint = 12
var reversed = false

var success = false # Stop animation if success and emit a signal in _process
var finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	startPoint = slider.get_position().x
	frameWidth = frame.texture.get_size().x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var currentPosition = slider.get_position()
	# Before moving, check if input detected and handle accordingly
	
	# Move Slider
	if !finished:
		move_slider(currentPosition)
	
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
	
	slider.set_position(position)
	if reverseThisTime:
		reversed = true

# Handle click action, check if succeeded
func handle_click(position):
	var winboxXPosition = winBox.get_position().x
	var winboxXSize = winBox.rect.get_size().x
	print(winboxXPosition)
	print(winboxXSize)
