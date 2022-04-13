extends Node

var questionText
var answer1Text
var answer2Text
var answer3Text
var answer4Text
var answer = 0
var time = 21
var timeTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	timeTimer = get_node("RemainingTimeTimer")
	_on_RemainingTimeTimer_timeout()
	timeTimer.set_wait_time(1)
	timeTimer.start()
	
func set_data(q, a1, a2, a3, a4):
	questionText = q
	answer1Text = a1
	answer2Text = a2
	answer3Text = a3
	answer4Text = a4

	load_data()

func load_data():
	$PanelQuestion/Question.text = questionText
	$PanelAnswers/Answer1.text = answer1Text
	$PanelAnswers/Answer2.text = answer2Text
	$PanelAnswers/Answer3.text = answer3Text
	$PanelAnswers/Answer4.text = answer4Text


func _on_Answer1_pressed():
	answer = 1


func _on_Answer2_pressed():
	answer = 2


func _on_Answer3_pressed():
	answer = 3


func _on_Answer4_pressed():
	answer = 4


func get_user_answer():
	return answer


func _on_RemainingTimeTimer_timeout():
	if time == 0:
		timeTimer.stop()
	time -= 1
	$RemainingTimeLabel.text = "Remaining time: " + str(time)
