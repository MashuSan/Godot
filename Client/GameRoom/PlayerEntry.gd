extends HBoxContainer

var player_id

func _ready():
	if Player._player_id != player_id:
		$Team.editable = false


func set_player_name(player_name):
	$Player_name_label.text = player_name


func set_team(team):
	if team == null:
		return

	$Team.text = team


func get_team():
	return $Team.text

func _on_Button_text_changed(new_text):
	if len(new_text) > 5:
		$Team.text = ""
		return
