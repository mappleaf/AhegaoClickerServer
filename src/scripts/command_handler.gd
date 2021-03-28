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
		[ARG_STRING, ARG_INT]]
]


func set_money(username, money) -> String:
	money = int(money)
	PlayerData.player_data[username].money = money
	PlayerData.save_player_data()
	
	for user in main_interface.user_peers.keys():
		if user == username:
			var peer = main_interface.user_peers[username]
			main_interface.get_node(str(peer)).money = money
			main_interface.send_user_money(peer)
	
	return str("Successfully set ", username, "'s money to", money)
