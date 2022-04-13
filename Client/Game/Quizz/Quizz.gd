extends Control

var welcomeTimer

var questionTimer

var question_scene

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if Player._is_host:
		GameManager.load_questions()

	welcomeTimer = get_node("Introduction/WelcomeTimer")
	welcomeTimer.set_wait_time(2)
	welcomeTimer.start()
	
	questionTimer = get_node("QuestionTimer")
	
	$Game/RemainingTime.text = str($QuestionTimer.time_left)

func _on_WelcomeTimer_timeout():
	$Introduction/WelcomeTimer.stop()
	$Introduction/Welcome.hide()
	$Introduction/Ready.hide()

	start_question()

	$Game.show()

	if Player._is_host:
		$Game/NextQuestion.visible = true

func show_question():
	question_scene = load("res://Game/Quizz/QuizzQuestion.tscn").instance()
	
	var answers = GameManager.get_answers(GameManager.get_question_number())
	var question = GameManager.get_question(GameManager.get_question_number())
	
	question_scene.set_data(question, answers[0], answers[1], answers[2], answers[3])

	questionTimer.start()
	$Game.add_child(question_scene)

func get_ready_question_timer():
	questionTimer.set_wait_time(20)
	questionTimer.start()

remote func start_question():
	get_ready_question_timer()
	show_question()

func show_score():
	$Game/Score.text = "Score : " + str(score)

func _on_QuestionTimer_timeout():
	# check_answer
	score += int(question_scene.get_user_answer() == GameManager.get_right_answer())
	question_scene.queue_free()
	show_score()
	$QuestionTimer.stop()
	var right_answer = GameManager.get_right_answer()
	var answer = GameManager.get_answer(GameManager.get_question_number() - 1, right_answer)
	$Game/RightAnswer.text = "The right answer was : " + str(right_answer) + ":" + str(answer)
	
	if question_scene.get_user_answer() == GameManager.get_right_answer():
		$Game/NoTexture.visible = false
		$Game/YesTexture.visible = true
	else:
		$Game/NoTexture.visible = true
		$Game/YesTexture.visible = false


	if GameManager.is_last_question():
		# show score screen
		$Game/NextQuestion.visible = false
		GameManager.call_adding(score)
		$Game/ShowResults.visible = true
		return


func _on_NextQuestion_pressed():
	for player_info in ServerManager._player_in_same_game_room_list:
		if player_info[0] != Player._player_id:
			rpc_id(player_info[0], "start_question")
	start_question()


func _on_ShowResults_pressed():
	get_tree().change_scene("res://Game/ScoreInfo.tscn")
