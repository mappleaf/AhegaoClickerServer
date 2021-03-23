extends Node

const player_data_name = "player_data.json"

onready var data_folder = "user://Data/"

var player_data = {}

func _ready() -> void:
	var directory = Directory.new()
	var file = File.new()
	
	if !directory.dir_exists(data_folder):
		directory.make_dir(data_folder)
	if !file.file_exists(data_folder + player_data_name):
		save_player_data()
	
	get_player_data()


func get_player_data() -> void:
	var player_data_file = File.new()
	player_data_file.open(data_folder + player_data_name, File.READ)
	player_data = parse_json(player_data_file.get_as_text())
	player_data_file.close()

func save_player_data() -> void:
	var save_file = File.new()
	save_file.open(data_folder + player_data_name, File.WRITE)
	save_file.store_line(to_json(player_data))
	save_file.close()


func _on_Timer_timeout():
	save_player_data()
