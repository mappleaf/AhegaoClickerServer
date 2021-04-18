extends Node

onready var main_interface = get_parent().get_parent()

enum {
	ARG_INT,
	ARG_FLOAT,
	ARG_BOOL,
	ARG_STRING
}

const valid_commands = [
	["set_money",
		[ARG_STRING, ARG_INT]],
	["save_player_data",
		[]],
	["set_gacha",
		[ARG_STRING, ARG_STRING, ARG_INT]],
	["set_stardust",
		[ARG_STRING, ARG_INT]],
	["stop",
		[]],
	["generate_weapon",
		[]]
]


func set_money(username, money) -> String:
	money = int(money)
	PlayerData.player_data[username].money = money
	
	for user in main_interface.user_peers.keys():
		if user == username:
			var peer = main_interface.user_peers[username]
			main_interface.get_node(str(peer)).money = money
			main_interface.send_user_money(peer)
			break
		else:
			return str("Cannot find user \"", username, "\"")
	
	return str("Successfully set ", username, "'s money to ", money)

func set_stardust(username, stardust) -> String:
	stardust = int(stardust)
	PlayerData.player_data[username].stardust = stardust
	
	for user in main_interface.user_peers.keys():
		if user == username:
			var peer = main_interface.user_peers[username]
			main_interface.get_node(str(peer)).stardust = stardust
			main_interface.send_user_stardust(peer)
			break
		else:
			return str("Cannot find user \"", username, "\"")
	
	return str("Successfully set ", username, "'s stardust to ", stardust)

func save_player_data() -> String:
	PlayerData.save_player_data()
	return str("Successfully saved player data")

func set_gacha(username, type, count) -> String:
	count = int(count)
	for user in main_interface.user_peers.keys():
		if user == username:
			var peer = main_interface.user_peers[username]
			match type:
				"starting":
					PlayerData.player_data[username].gacha_starting = count
					main_interface.get_node(str(peer)).gacha_starting = count
				"regular":
					PlayerData.player_data[username].gacha_regular = count
					main_interface.get_node(str(peer)).gacha_regular = count
				"special":
					PlayerData.player_data[username].gacha_special = count
					main_interface.get_node(str(peer)).gacha_special = count
				_:
					return str("Cannot resolve \"", type, "\" gacha type")
			
			break
		else:
			return str("Cannot find user \"", username, "\"")
	
	return str("Successfully set ", username, "'s gacha to ", count, " of type \"", type, "\"")

func stop() -> void:
	PlayerData.save_player_data()
	get_tree().quit()

func generate_weapon() -> String:
	return main_interface.GenerateWeapon()
