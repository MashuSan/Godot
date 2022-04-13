extends Node

var answers_left = []
var answers_right = []
var position = 0
var questions = {}

func _ready():
	answers_left = [$PanelAnswersLeft/Answer1, $PanelAnswersLeft/Answer2,
			   $PanelAnswersLeft/Answer3, $PanelAnswersLeft/Answer4]
			
	answers_right = [$PanelAnswersRight/Answer1, $PanelAnswersRight/Answer2,
			   $PanelAnswersRight/Answer3, $PanelAnswersRight/Answer4]


func _on_AddSetButton_pressed():
	ServerManager.save_game_questions($AddSetText.text + ".xml", ServerManager.game_modes[1], questions)
	self.queue_free()


func reset_texts():
	for answer in answers_left:
		answer.text = ""
	
	for answer in answers_right:
		answer.text = ""


func _on_ExitButton_pressed():
	self.queue_free()


func _on_AddQuestionButton_pressed():
	var txt_left = []
	for ans in answers_left:
		txt_left.append(ans.text)
	
	var txt_right = []
	for ans in answers_right:
		txt_right.append(ans.text)

	questions[position] = [txt_left, txt_right]
	position += 1
	
	reset_texts()
