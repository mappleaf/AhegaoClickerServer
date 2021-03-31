extends Node

var units_list = {}
var enemies = {}

var starting_data = {
	"owned_units": {
		TEST = "res://src/scenes/units/TestUnit.tscn"
	},
	"units_in_room": {},
	"money": 100,
	"gacha_starting": 10,
	"gacha_regular": 0,
	"gacha_special": 0,
	"enemy": {
		enemy_name = "Goblin",
		texture_location = "res://assets/test/klipartz.com.png",
		max_health = 100,
		health = 100,
		health_factor = 0.75,
		modificators = [0, 1, 2, 3],
		min_money = 10,
		max_money = 50
	},
	"level": 1
}

func _ready() -> void:
#	var units_list_file = File.new()
#	units_list_file.open("res://Data/units_list.json", File.READ)
#	var units_list_json = JSON.parse(units_list_file.get_as_text())
#	units_list_file.close()
#	units_list = units_list_json.result
#	print(units_list)

	get_units()
	get_enemies()


func get_units() -> void:
	var units_list_file = File.new()
	units_list_file.open("res://Data/units_list.json", File.READ)
	units_list = parse_json(units_list_file.get_as_text())
	units_list_file.close()

func get_enemies() -> void:
	var enemies_file = File.new()
	enemies_file.open("res://Data/enemies_list.json", File.READ)
	enemies = parse_json(enemies_file.get_as_text())
	enemies_file.close()
