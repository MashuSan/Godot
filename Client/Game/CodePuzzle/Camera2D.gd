extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var is_button_down = false
var down_position = position
var up_position = position
var position_y = position.y
var thread = Thread.new()
var event

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(a):
	if is_button_down and position != null and down_position != null and event != null:
		if position.y - ((down_position.y - event.position.y) / 20) >= 5000:
			return
		if position.y - ((down_position.y - event.position.y) / 20) <= 360:
			return
		if is_button_down:
			position.y -= (down_position.y - event.position.y) / 20

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		self.event = event
			
	if event is InputEventMouseButton:
		if event.is_pressed():
			if not is_button_down:
				is_button_down = true
				down_position = event.position

		else:
			if is_button_down:
				is_button_down = false
				
			
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
"""
if event is InputEventMouseButton:
		if event.is_pressed():
			if not is_button_down:
				is_button_down = true
				down_position = event.position

		else:
			if is_button_down:
				is_button_down = false
				if event.position.y < down_position.y:
					position.y -= (down_position.y - event.position.y)
				else:
					position.y -= (down_position.y - event.position.y)
"""
