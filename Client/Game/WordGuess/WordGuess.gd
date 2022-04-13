extends Control

var list_of_players = []
var word_describing_player = [0, "name"]
onready var insert_text = get_node("Describing/InsertText")
onready var show_text = get_node("Describing/ShowText")
onready var logger = get_node("Logger/TextEdit")
var score = 0
var time = 60


func _ready():
	list_of_players = ServerManager._player_in_same_game_room_list
	
	if Player._is_host:
		$NextDescriberButton.visible = true
		$ExitButton.visible = true
	
	for player in list_of_players:
		var player_control = load("res://Game/WordGuess/WordGuessPlayer.tscn").instance()
		player_control.set_name(player[1])
		
		$Players/ScrollContainer/HSplitContainer.add_child(player_control)

remote func ready_start_game():
	$SetWordGuess.visible = false
	$Describing.visible = false
	$Logger.visible = false
	$Describing/ShowText.text = ""
	reset_player_checkboxes()
	$RoundTimer.stop()

	if Player._player_id == word_describing_player[0]:
		$SetWordGuess.visible = true

remote func visible_guess_parts():
	$RoundTimer.set_wait_time(1)
	time = 60
	$RoundTimer.start()
	$Describing.visible = true
	$Logger.visible = true
	$Describing/InsertText.readonly = false
	$Describing/SendButton.disabled = false

func guess_word_chosen(text):
	GameManager.set_word_guess(text)
	$SetWordGuess.visible = false
	
	for player_info in list_of_players:
		if player_info[0] != Player._player_id:
			rpc_id(player_info[0], "visible_guess_parts")
	
	visible_guess_parts()


func random_describer():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var pos = rng.randi_range(0, len(list_of_players) - 1)
	
	word_describing_player = list_of_players[pos]	
	
	for player_info in list_of_players:
		if Player._player_id != player_info[0]:
			rpc_id(player_info[0], "set_describing_player", word_describing_player)
			rpc_id(player_info[0], "ready_start_game")
	
	set_describing_player(word_describing_player)
	ready_start_game()
	

remote func set_describing_player(player_info):
	word_describing_player = player_info

remote func add_text_from_describer(text):
	add_text_to_show_text(text)

remote func player_guess_right(player_name):
	for player in $Players/ScrollContainer/HSplitContainer.get_children():
		if player.get_name() == player_name:
			player.increase_score()
			player.set_right_guess()
			break

func reset_player_checkboxes():
	for player in $Players/ScrollContainer/HSplitContainer.get_children():
		player.reset_check_box()

func _on_SendButton_pressed():
	var text = $Describing/InsertText.text
	text.trim_prefix(" ")
	text.trim_suffix(" ")

	if Player._player_id == word_describing_player[0]:
		add_text_to_show_text(text)
		for player_info in list_of_players:
			if player_info[0] != Player._player_id:
				rpc_id(player_info[0], "add_text_from_describer", text)
	elif text == GameManager.guess_word:
		for player_info in list_of_players:
			if player_info[0] != Player._player_id:
				rpc_id(player_info[0], "player_guess_right", Player._player_name)
		player_guess_right(Player._player_name)
		score += 1
		logger.text += "*" + text + " is correct*\n"
		start_correct_timeout()
	else:
		logger.text += text + " is incorrect\n"

	insert_text.text = ""


func add_text_to_show_text(text):
	show_text.text += text + "\n"

func start_correct_timeout():
	$CorrectTimer.set_wait_time(3)
	$CORRECTLabel.visible = true
	$Describing/InsertText.readonly = true
	$Describing/SendButton.disabled = true
	$CorrectTimer.start()

func _on_CorrectTimer_timeout():
	$CorrectTimer.stop()
	$CORRECTLabel.visible = false


func _on_SubmitWordGuess_pressed():
	guess_word_chosen($SetWordGuess/SubmitWordText.text)


func _on_NextDescriberButton_pressed():
	random_describer()


func _on_RoundTimer_timeout():
	if time > 0:
		time -= 1
		$RemainingTimeLabel/TimeLabel.text = str(time)
	else:
		$RoundTimer.stop()
		$Describing/InsertText.readonly = true
		$Describing/SendButton.disabled = true
		reset_player_checkboxes()

remote func exit_game():
	get_tree().change_scene("res://Game/ScoreInfo.tscn")

remote func end_game():
	GameManager.call_adding(score)
	$ExitButton.text = "EXIT"

func _on_Button_pressed():
	
	for player in list_of_players:
		if Player._player_id != player[0]:
			if $ExitButton.text == "SUBMIT":
				rpc_id(player[0], "end_game")
			else:
				rpc_id(player[0], "exit_game")

	if $ExitButton.text == "SUBMIT":
		end_game()
	else:
		exit_game()

