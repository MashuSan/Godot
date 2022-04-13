extends Control

var questions_file = ""
var files = []
var game_mode
var player_node

func _ready():
	for player_id in ServerManager._open_games[Player.get_game_id()][3]:
		if player_id != Player.get_player_id():
			rpc_id(player_id, "update_game_room_player_list")

	update_game_room_player_list()
	$Start_button.disabled = questions_file == ""
	if Player.is_host():
		$ChooseSet.visible = true
		$CreateQuestion_button.visible = true
	
	game_mode = ServerManager._open_games[Player.get_game_id()][4]
	
	if ServerManager.game_modes[game_mode] == "WordGuess":
		$Start_button.disabled = false

remote func update_game_room_player_list():
	ServerManager.send_open_games_request_to_server()
	yield(ServerManager, "updated_games")

	for child in $Player_list/ScrollContainer/Player_list_container.get_children():
		child.queue_free()
	
	ServerManager._player_in_same_game_room_list = []
	
	for player_id in ServerManager._open_games[Player.get_game_id()][3]:
		add_player_entry_to_list(player_id)

func set_q_file(name):
	ServerManager.get_game_questions(game_mode, name)
	$GameSet.hide()
	$Start_button.disabled = false

func add_player_entry_to_list(player_id):
	var player = load("res://GameRoom/PlayerEntry.tscn").instance()
	player.player_id = player_id
	
	if player_id == Player._player_id:
		player_node = player

	var player_i = ServerManager._open_games[Player.get_game_id()][3][player_id]
	player.set_player_name(player_i[0])
	player.set_team(player_i[4])
	$Player_list/ScrollContainer/Player_list_container.add_child(player)
	var player_info = [player_id, player_i[0]]
	ServerManager._player_in_same_game_room_list.append(player_info)

func _on_Game_room_tree_entered():
	if Player.is_host() || Player.is_admin():
		$Start_button.show()
	else:
		$Start_button.hide()

func _on_Start_button_pressed():
	for player_id in ServerManager._player_in_same_game_room_list:
		if player_id[0] != Player.get_player_id():
			rpc_id(player_id[0], "start_game")
	start_game()

remote func start_game():
	#var game = preload("res://Game/Quizz/Quizz.tscn").instance()
	#game.load_questions()
	#get_tree().get_root().add_child(game)
	#get_tree().change_scene("res://Game/Quizz/Quizz.tscn")
	var mode = ServerManager.game_modes[game_mode]
	GameManager.game_mode = mode
	
	var list_of_players = ServerManager._open_games[Player._game_id][3]
	
	for player_id in list_of_players:
		var team_name = list_of_players[player_id][4]
		
		if team_name in ServerManager._player_in_same_team:
			ServerManager._player_in_same_team[team_name].append(player_id)
		else:
			ServerManager._player_in_same_team[team_name] = [player_id]
	
	match mode:
		"Quizz":
			add_child(load("res://Game/Quizz/Quizz.tscn").instance())
		"WordPairing":
			add_child(load("res://Game/WordPairing/WordPairingGame.tscn").instance())
		"CodePuzzle":
			add_child(load("res://Game/CodePuzzle/CodePuzzle.tscn").instance())
		"WordGuess":
			add_child(load("res://Game/WordGuess/WordGuess.tscn").instance())

remote func leave_game():
	ServerManager.left_game()
	Player.set_game_id(0)
	get_tree().change_scene("res://GameData/Lobby.tscn")

func _on_Leave_button_pressed():
	if Player.is_host():
		for player_id in ServerManager._player_in_same_game_room_list:
			if player_id[0] != Player.get_player_id():
				rpc_id(player_id[0], "leave_game")
		
		ServerManager.close_game()
		ServerManager.left_game()
	
	else:
		ServerManager.left_game()
		yield(ServerManager, "updated_games")
		for player in ServerManager._open_games[Player.get_game_id()][3]:
			if player != Player.get_player_id():
				rpc_id(player, "update_game_room_player_list")
		
	Player.set_game_id(0)
	get_tree().change_scene("res://GameData/Lobby.tscn")
	#which game belongs to this player


func _on_ChooseSet_pressed():
	files = ServerManager.get_game_mode_files()
	
	for child in $GameSet/ScrollContainer/GameModesContainer.get_children():
		child.queue_free()
	
	for file in files:
		add_set_to_list(file)
	
	$GameSet.show()


func add_set_to_list(file):
	var new_set = load("res://GameRoom/GameSet.tscn").instance()
	new_set.set_text(file.get_basename(), "12")
	new_set.connect("clicked_on", self, "set_q_file")
	$GameSet/ScrollContainer/GameModesContainer.add_child(new_set)


func _on_CreateQuestion_button_pressed():
	var mode = ServerManager.game_modes[game_mode]
	
	match mode:
		"Quizz":
			add_child(load("res://Game/Quizz/QuizzQuestionMaker/QuizzQuestionMaker.tscn").instance())
		"WordPairing":
			add_child(load("res://Game/WordPairing/WordPairingQuestionMaker/WordPairingQuestionMaker.tscn").instance())
		"CodePuzzle":
			add_child(load("res://Game/CodePuzzle/CodePuzzleQuestionMaker/CodePuzzleQuestionMaker.tscn").instance())


func _on_Ready_button_pressed():
	$Ready_button.disabled = true
	Player.set_team(player_node.get_team())
	ServerManager.update_player_team(Player._player_id, Player._game_id, player_node.get_team())
	update_game_room_player_list()
	
	for player_id in ServerManager._open_games[Player.get_game_id()][3]:
		if player_id != Player.get_player_id():
			rpc_id(player_id, "update_game_room_player_list")
	
