extends Node

var units_list = {}

func _ready() -> void:
#	var units_list_file = File.new()
#	units_list_file.open("res://Data/units_list.json", File.READ)
#	var units_list_json = JSON.parse(units_list_file.get_as_text())
#	units_list_file.close()
#	units_list = units_list_json.result
#	print(units_list)

	get_units()


func get_units() -> void:
	var units_list_file = File.new()
	units_list_file.open("res://Data/units_list.json", File.READ)
	units_list = parse_json(units_list_file.get_as_text())
	units_list_file.close()
