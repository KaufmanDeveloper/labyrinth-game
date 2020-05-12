extends Control

signal finished()

export (int) var speed

onready var sliderArea = $SliderArea
onready var winBox1 = $WinBoxArea1/WinBox1
onready var winBox2 = $WinBoxArea2/WinBox2
onready var winBox3 = $WinBoxArea3/WinBox3

const maxClicks = 3
const successClickColor = Color(0.13, 0.98, 0.9, 1)

var successes = [false, false, false]
var clicks = 0
var finished = false

var inWinBoxArea1 = false
var inWinBoxArea2 = false
var inWinBoxArea3 = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	var currentPosition = sliderArea.get_position()
	
	# Move Slider
	if !finished:
		move_slider(currentPosition)
	else:
		emit_signal("finished")
	
	if Input.is_action_just_pressed("ui_accept"):
		handle_click(currentPosition)

# Handle click action, check if succeeded
func handle_click(position):
	if (inWinBoxArea1):
		winBox1.set_frame_color(successClickColor)
		successes[0] = true
	elif (inWinBoxArea2):
		winBox2.set_frame_color(successClickColor)
		successes[1] = true
	elif (inWinBoxArea3):
		winBox3.set_frame_color(successClickColor)
		successes[2] = true
	
	clicks += 1
	if (clicks >= maxClicks):
		handle_finished()

# Handle movement of slider
func move_slider(position):
	var moveAmount = speed * .7
	position.x += moveAmount
	
	sliderArea.set_position(position)

func handle_finished():
	finished = true
	emit_signal("finished")

func _on_WinBoxArea1_area_entered(area):
	inWinBoxArea1 = true

func _on_WinBoxArea1_area_exited(area):
	inWinBoxArea1 = false

func _on_WinBoxArea2_area_entered(area):
	inWinBoxArea2 = true

func _on_WinBoxArea2_area_exited(area):
	inWinBoxArea2 = false

func _on_WinBoxArea3_area_entered(area):
	inWinBoxArea3 = true

func _on_WinBoxArea3_area_exited(area):
	inWinBoxArea3 = false

func _on_LossArea_area_entered(area):
	handle_finished()
