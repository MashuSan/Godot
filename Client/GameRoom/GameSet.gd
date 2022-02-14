extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal clicked_on

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_text(name, number_of_q):
	$HBoxContainer/GameSet.text = name
	$HBoxContainer/NumberOfQuestions.text = number_of_q

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_GameSet_pressed():
	emit_signal("clicked_on", $HBoxContainer/GameSet.text)
