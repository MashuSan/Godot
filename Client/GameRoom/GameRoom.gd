extends Control

var questions_file = ""
var files = []
var game_mode

func _ready():
	for player_id in ServerManager._open_games[Player.get_game_id()][3]:
		if player_id != Player.get_player_id():
			rpc_id(player_id, "update_game_room_player_list")
		
	update_game_room_player_list()
	$Start_button.disabled = questions_file == ""
	if Player.is_host():
		$ChooseSet.visible = true
	
	game_mode = ServerManager._open_games[Player.get_game_id()][4]

remote func update_game_room_player_list():
	ServerManager.send_open_games_request_to_server()
	yield(ServerManager, "updated_games")

	for child in $Player_list/ScrollContainer/Player_list_container.get_children():
		child.queue_free()
	
	ServerManager._player_in_same_game_room_list = []
	
	for player_id in ServerManager._open_games[Player.get_game_id()][3]:
		add_player_entry_to_list(player_id)

func set_q_file(name):
	ServerManager.get_game_questions(ServerManager.game_modes[0], name)
	$GameSet.hide()
	$Start_button.disabled = false

func add_player_entry_to_list(player_id):
	var player = load("res://GameRoom/PlayerEntry.tscn").instance()
	var player_name = str(ServerManager._open_games[Player.get_game_id()][3][player_id][0])
	player.set_player_name(player_name)
	$Player_list/ScrollContainer/Player_list_container.add_child(player)
	var player_info = [player_id, player_name]
	ServerManager._player_in_same_game_room_list.append(player_info)

func _on_Game_room_tree_entered():
	if Player._is_host:
		$Start_button.show()
		$Ready_button.hide()
	else:
		$Start_button.hide()
		$Ready_button.hide() # TODO: change this to .show(), if ready-feature is implemented.

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
	get_tree().change_scene("res://Game/Quizz/Quizz.tscn")

remote func leave_game():
	get_tree().change_scene("res://GameData/Lobby.tscn")

func _on_Leave_button_pressed():
	if Player.is_host():
		for player_id in ServerManager._player_in_same_game_room_list:
			if player_id[0] != Player.get_player_id():
				rpc_id(player_id[0], "leave_game")
		
		ServerManager.close_game()
	
	else:
		ServerManager.left_game()
		yield(ServerManager, "updated_games")
		for player in ServerManager._open_games[Player.get_game_id()][3]:
			print(player)
			if player != Player.get_player_id():
				rpc_id(player, "update_game_room_player_list")
	
	#which game belongs to this player
	Player.set_game_id(0)
	get_tree().change_scene("res://GameData/Lobby.tscn")


func _on_ChooseSet_pressed():
	files = ServerManager.get_game_mode_files()
	
	for file in files:
		add_set_to_list(file)
	
	$GameSet.show()


func add_set_to_list(file):
	var new_set = load("res://GameRoom/GameSet.tscn").instance()
	new_set.set_text(file.get_basename(), "12")
	new_set.connect("clicked_on", self, "set_q_file")
	$GameSet/ScrollContainer/GameModesContainer.add_child(new_set)
