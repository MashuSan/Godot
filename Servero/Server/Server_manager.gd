extends Node
# {game_id:[_game_id, _game_name, _max_players, _player_list]} # player_list is a dict
# {game_id:[_game_id, _game_name, _max_players, {player_id:[_player_name, _player_id, _game_id, _is_host, _team]}]}
var _open_games = {}
var _players_connected = []

remote func get_open_games_from_server(id):
	rpc_id(id, "update_open_games", _open_games)

remote func send_game_questions(game_mode, file_name, player_id):
	rpc_id(player_id, "update_game_questions", FileWorker.get_questions(game_mode, file_name))
	LogWorker.PrintLog("Sending questions to " + str(player_id) + " from path: " + game_mode + " " + file_name)

remote func update_player_team(player_id, game_id, team_name):
	_open_games[game_id][3][player_id][4] = team_name

remote func save_game_questions(set_name, game_mode, questions):
	FileWorker.save_questions(set_name, game_mode, questions)
	LogWorker.PrintLog("Saving questions: " + set_name + " " + game_mode)

remote func add_game_to_game_list(game_id, game_information, host_player):
	_open_games[game_id] = game_information
	add_player_to_open_game(game_id, host_player)
	LogWorker.PrintLog(str(host_player[1]) + " created game with id: " + str(game_id))
	LogWorker.PrintLog("Adding game to the list :" + str(game_id))
	get_open_games_from_server(game_id)

remote func get_game_mode_files(file_path, player_id):
	rpc_id(player_id, "update_set_files", FileWorker.get_files(file_path))

remote func join_open_game(game_id, player_information):
	add_player_to_open_game(game_id, player_information)
	LogWorker.PrintLog("Player = " + str(player_information[1]) + " joining to game: " + str(game_id))

func add_player_to_open_game(game_id, player_information):
	_open_games[game_id][3][player_information[1]] = player_information
	LogWorker.PrintLog("Player = " + str(player_information[1]) + " joining to game: " + str(game_id))

remote func remove_player_from_open_game(game_id, player_id):
	_open_games[game_id][3].erase(player_id)
	LogWorker.PrintLog("Removing player = " + str(player_id) + " from game: " + str(game_id))

remote func remove_game_from_game_list(game_id):
	_open_games.erase(game_id)
	LogWorker.PrintLog("Removing game from the list: " + str(game_id))
