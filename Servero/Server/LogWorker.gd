extends Node

var logWindow

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_control(control):
	logWindow = control

# Called when the node enters the scene tree for the first time.
func PrintLog(text):
	print(text)
	logWindow.text += text + "\n"



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
