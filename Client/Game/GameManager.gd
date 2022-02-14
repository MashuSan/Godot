extends Node

var questions = {}

var questions_array = []

var right_answers = []

var questionNumber = 0

var score_board = []

func load_questions():
	load_questions_clients(ServerManager.get_questions())

	for player_info in ServerManager._player_in_same_game_room_list:
		if player_info[0] != Player._player_id:
			rpc_id(player_info[0], "load_questions_clients", questions)

remote func add_to_board(data):
	score_board.append(data)

remote func load_questions_clients(qs):
	questions = qs
	questions_array = qs.keys()
	
	for q in questions:
		right_answers.append(questions[q][1])

"""
func set_questions(qs):
	questions = qs
	questions_array = questions.keys()
	
	for q in questions:
		right_answers.append(questions[q][1])
"""
func get_answers(index):
	return questions[questions_array[index]][0]

func get_answer(qindex, qanswer):
	return questions[questions_array[qindex]][0][qanswer - 1]

func get_question(index):
	var q = questions_array[index]
	questionNumber += 1
	
	return q

func get_questions():
	return questions_array

func get_questions_size():
	return len(questions_array)

func get_question_number():
	return questionNumber

func get_right_answer():
	return right_answers[questionNumber - 1]
