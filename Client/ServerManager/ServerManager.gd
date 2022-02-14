extends Node

signal updated_games
signal all_ready

# {game_id:[_game_id, _game_name, _max_players, {player_id:[_player_name, _player_id, _game_id, _is_host]}, mode]}
var _open_games = {}
var _player_in_same_game_room_list = []
var _players_ready = []

var game_modes = {0: "Quizz"}
var questions
var files

func send_open_games_request_to_server():
	rpc_id(1, "get_open_games_from_server", get_tree().get_network_unique_id())

remote func update_open_games(open_games):
	_open_games = open_games
	print(_open_games)
	emit_signal("updated_games")

func save_game_questions(set_name, game_mode, questions):
	rpc_id(1, "save_game_questions", set_name, game_mode, questions)

func get_game_questions(game_mode, file_name):
	rpc_id(1, "send_game_questions", game_mode, file_name, get_tree().get_network_unique_id())

func update_game_mode_files(game_mode):
	rpc_id(1, "get_game_mode_files", game_mode, get_tree().get_network_unique_id())

func get_game_mode_files():
	return files

remote func update_set_files(fls):
	files = fls

remote func update_game_questions(qs):
	questions = qs

func get_open_games():
	return _open_games

func get_questions():
	return questions

func create_game(game_information, host_player):
	Player.set_game_id(host_player.get_player_id())
	Player.set_host(true)
	rpc_id(1, "add_game_to_game_list", host_player.get_player_id(), game_information, host_player.get_parsable_player())
	yield(ServerManager, "updated_games")
	update_game_mode_files(game_modes[0])
	get_tree().change_scene("res://GameRoom/GameRoom.tscn")

func join_game(game_id):
	Player.set_game_id(game_id)
	Player.set_host(false)
	rpc_id(1, "join_open_game", game_id, Player.get_parsable_player())
	get_tree().change_scene("res://GameRoom/GameRoom.tscn")

func left_game():
	rpc_id(1, "remove_player_from_open_game", Player.get_game_id(), Player.get_player_id())

	send_open_games_request_to_server()

func _on_Server_is_reachable_timeout():
	print("Server is reachable.")
	# TODO: check if connection still exists.

func close_game():
	rpc_id(1, "remove_game_from_game_list", Player.get_game_id())

func send_ready_signal():
	if Player.is_host():
		send_host_ready_signal(Player.get_player_id())
	else:
		rpc_id(Player.get_game_id(), "send_host_ready_signal", Player.get_player_id())

remote func send_host_ready_signal(id):
	print(str(id) + " is ready.")
	_players_ready.append(id)
	if len(_players_ready) == len(_player_in_same_game_room_list):
		emit_signal("all_ready")
