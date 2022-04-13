extends Node

var _game_id
var _game_name
var _game_mode
var _max_players
var _player_list
var _question_time

func _init(game_id, game_name, game_mode, max_players):
	_game_id = game_id
	_game_name = game_name
	_game_mode = game_mode
	_max_players = max_players
	_player_list = {}

func get_parsable_game_information():
	return [_game_id, _game_name, _game_mode, _max_players, _player_list]

func get_question_time():
	return _question_time

func add_player_to_game(player):
	_player_list.append(player)

func remove_player_from_game():
	pass

func set_game_id(game_id):
	_game_id = game_id

func set_game_name(game_name):
	_game_name = game_name

func set_game_mode(game_mode):
	_game_mode = game_mode

func set_max_players(max_players):
	_max_players = max_players

func set_question_time(time):
	_question_time = time

func is_full():
	return _max_players <= len(_player_list)
