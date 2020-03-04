extends Node

export (int) var speed

onready var frame = $Frame
onready var slider = $Slider

var startPoint
var frameWidth
var reversePoint
var missedPoint

# Called when the node enters the scene tree for the first time.
func _ready():
	startPoint = slider.get_position().x
	frameWidth = frame.texture.get_size().x
	print(startPoint)
	print(frameWidth)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var currentPosition = slider.get_position()
	currentPosition.x += speed * .7
	slider.set_position(currentPosition)
