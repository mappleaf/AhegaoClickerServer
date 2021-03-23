extends Node

var units_list = {}
var test_data = {
	"owned_units": {
		TEST = "res://src/scenes/units/TestUnit.tscn"
	},
	"units_in_room": {}
}
var starting_data = {
	"owned_units": {
		TEST = "res://src/scenes/units/TestUnit.tscn"
	},
	"units_in_room": {},
	"money": 100,
	"gacha_starting": 10,
	"gacha_regular": 0,
	"gacha_special": 0
}

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
