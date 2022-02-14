extends Node

var questions = {}
var question
var answers = []
var right_answer

func _ready():
	question = $PanelQuestion/Question
	answers = [$PanelAnswers/Answer1, $PanelAnswers/Answer2,
			   $PanelAnswers/Answer3, $PanelAnswers/Answer4]
	right_answer = $PanelAnswers/OptionButton


func _on_Button_pressed():
	questions[question.text] \
	= [[answers[0].text, answers[1].text, 
	   answers[2].text, answers[3].text], int(right_answer.text)]
	
	reset_texts()


func _on_AddSetButton_pressed():
	ServerManager.save_game_questions($AddSetText.text + ".xml", ServerManager.game_modes[0], questions)
	reset_texts()


func reset_texts():
	question.text = ""
	answers[0].text = ""
	answers[1].text = ""
	answers[2].text = ""
	answers[3].text = ""


func _on_ExitButton_pressed():
	self.queue_free()
